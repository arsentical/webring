$name = "";
$page = "";
$link = "";
$text = "";

@list_name = ();
@list_page = ();
@list_link = ();
@list_text = ();

sub read_all {
	local $/;
	$out = <FILE>;
	close FILE;
	return $out
}

sub output {
	chop($TMP = `mktemp`);
	open(FILE, ">$TMP");
	print FILE $text;
	close FILE;
	open(FILE, "pandoc $TMP -r markdown -w html|");
	push(@list_name, $name);
	push(@list_page, $page);
	push(@list_link, $link);
	do read_all;
	push(@list_text, $out);
}

while (<>) {
	if (/^# \[(.*?)\]\((.*)\) >(.*?)$/) {
		do output if $name;
		$name = $1;
		$page = $3;
		$link = $2;
		$text = "";
	} else {
		$text = $text . "\n" . $_;
	}
}
do output;

$user_list = "";
$user_text = "";

open(FILE, "<tpl_index.html");
do read_all;
$tpl_index = $out;

open(FILE, "<tpl_user.html");
do read_all;
$tpl_user = $out;

$len = $#list_name;
for $i (0..$len) {
	$name = $list_name[$i];
	$prev_name = $list_name[($i - 1) % ($len + 1)];
	$next_name = $list_name[($i + 1) % ($len + 1)];
	$page = $list_page[$i];
	$link = $list_link[$i];
	$prev_link = $list_link[($i - 1) % ($len + 1)];
	$next_link = $list_link[($i + 1) % ($len + 1)];
	$text = $list_text[$i];
	$idx = $i + 1;
	$user_list = $user_list . "\n<li><a href=\"$link\">$name</a></li>";
	$user_text = $user_text . "\n<div id=\"p$idx\">\n$text</div>";
	$_ = $tpl_user;
	s/\[prev_name\]/$prev_name/;
	s/\[prev_link\]/$prev_link/;
	s/\[next_name\]/$next_name/;
	s/\[next_link\]/$next_link/;
	open(FILE, ">docs/user/$page");
	print FILE $_;
	close FILE;
}

$_ = $tpl_index;
s/\[user_list\]/$user_list/;
s/\[user_text\]/$user_text/;
open(FILE, ">docs/index.html");
print FILE $_;
close FILE;
