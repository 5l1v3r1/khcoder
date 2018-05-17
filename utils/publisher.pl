use strict;
use utf8;

# core_uni/pub/base 以下に：
#	/web
#	/win_pkg  →現行のWindows版パッケージを解凍しておく
#	# /win_upd  →現行のWindows版バイナリを解凍しておく
#	# /win_strb →現行のWindows・Strawberry版を解凍しておく

# 配布パッケージに新しいファイルを加える場合は @cp_f を編集（後ろに追加）
# 新たなPerlモジュールを使い始める場合にはStrawberry Perlの編集が必要

$Archive::Tar::DO_NOT_USE_PREFIX = 1;

# 初期設定
my $V = '3a13d';
my $V_main = "3.Alpha.13"; # フォルダ名
my $V_full = "3.Alpha.13d";

# マニュアル・チュートリアルのPDFを再作成するか
my $pdf = 0;

# 環境設定
my $home_dir;
my $key_file;
my $github_token;

if ( -e "f:/home/koichi/study/.ssh/id_dsa" ) { # Home
	$key_file = 'f:/home/koichi/study/.ssh/id_dsa';
	$home_dir = 'f:/home/koichi/study/';
	$github_token = "f:/home/Koichi/Google Drive/KHC/SSH-Key-Github/token";
}
elsif (-e "C:/Users/K/GoogleDrive/KHC/.ssh/id_dsa") { # Vaio
	$key_file = 'C:/Users/K/GoogleDrive/KHC/.ssh/id_dsa';
	$home_dir = 'C:/Users/K/GoogleDrive/KHC/';
} else {
	die("No ssh key!");
}
system("set HOME=$home_dir");

# 更新するファイルの指定
my @cp_f = (
	['kh_coder.exe' , 'kh_coder.exe'  ],
	['khc.xla'      , 'khc.xla'       ],
	['config/msg.en', 'config/msg.en' ],
	['config/msg.jp', 'config/msg.jp' ],
	['config/msg.es', 'config/msg.es' ],
	['config/msg.cn', 'config/msg.cn' ],
	['config/msg.kr', 'config/msg.kr' ],
);

use File::Find 'find';
find(
	sub {
		if ($_ =~ /\.pm$/ || $_ =~ /\.r$/){
			push @cp_f, ['plugin_en/'.$_, 'plugin_en/'.$_]
				unless -d $File::Find::name
			;
		}
	},
	'../plugin_en'
);

find(
	sub {
		if ($_ =~ /\.pm$/ || $_ =~ /\.r$/){
			push @cp_f, ['plugin_jp/'.$_, 'plugin_jp/'.$_]
				unless -d $File::Find::name
			;
		}
	},
	'../plugin_jp'
);

# 古いプラグインはすべて削除
find(
	sub {
		unlink $_ or die($File::Find::name) unless -d $_;
	},
	'../pub/win_pkg/plugin_en'
);

find(
	sub {
		unlink $_ or die unless -d $_;
	},
	'../pub/win_pkg/plugin_jp'
);


#------------------------------------------------------------------------------
#                                     実行
#------------------------------------------------------------------------------

#&web;
	#&pdfs if $pdf;
#&source_tgz;
#&win_pkg;
	#&win_upd;
	#&win_strb;
&upload;


use Archive::Tar;
use File::Copy;
use File::Copy::Recursive 'dircopy';
use Win32::Process;
use Time::Piece;
use Net::SFTP::Foreign;
use LWP::UserAgent;
use File::Path 'rmtree';
use Encode;

sub upload{
	# Create a tag on Github
	system("git tag -a $V_full -m \"$V\"");
	system("git push origin $V_full");
	
	# Create a release on Github using github-release
	#    https://github.com/aktau/github-release
	
	# I get "error: could not upload, status code (504 Gateway Time-out)"
	# Any Idea?
	
	open my $fh, '<', $github_token or die;
	my $token = <$fh>;
	close $fh;
	$ENV{GITHUB_TOKEN} = $token;
	
	system("github-release release --user ko-ichi-h --repo khc --tag $V_full --name $V_full --description \"$V\" ");
	
	print "Uploading...\n";
	system("github-release upload --user ko-ichi-h --repo khc --tag $V_full --name \"khcoder-$V.exe\" --file khcoder-$V.exe ");
	
	
	
	
	if ( 0 ){
		# Connect to SourceForge
		my $sftp = Net::SFTP::Foreign->new(
			host => 'web.sourceforge.net',
			user => 'ko-ichi,khc',
			key_path => $key_file,
		);

		# Upload binary files to SourceForge
		#$sftp->setcwd("/home/pfs/project/khc/KH Coder");
		#$sftp->mkdir($V_main);
		#$sftp->setcwd($V_main);
		#foreach my $i (
		#	"khcoder-$V.tar.gz",
		#	"khcoder-$V.exe",
		#){
		#	next unless -e $i;
		#	print "put: $i\n";
		#	$sftp->put ($i, $i) or die;
		#}

		# Upload web pages to SourceForge
		$sftp->setcwd("/home/project-web/khc/htdocs");
		foreach my $i (
			"index.html",
			"dl3.html",
		){
			$sftp->put ("../pub/web/$i", $i) or die;
		}
		$sftp->setcwd("en");
		$sftp->put ("../pub/web/en_index.html", "index.html") or die;
		$sftp->disconnect;
	}
}


sub web{
	my $ua = LWP::UserAgent->new(
		agent      => 'Mozilla/5.0 (Windows NT 6.1; rv:19.0) Gecko/20100101 Firefox/19.0',
	);
	
	# 日付
	my $time = localtime;
	my $year = $time->year;
	my $mon  = $time->mon;
	my $day  = $time->mday;
	$mon = '0'.$mon if $mon < 10;
	$day = '0'.$day if $day < 10;
	my $date = "$year $mon/$day";
	
	my $t = '';
	
	# index.html
	my $r0 = $ua->get('http://khc.sourceforge.net/index.html') or die;
	$t = '';
	$r0->is_success or die;
	$t = Encode::decode('cp932', $r0->content);
	$t =~ s/\x0D\x0A|\x0D|\x0A/\n/g; # 改行コード
	
	$t =~ s/KH Coder 3（最新アルファ版）ダウンロード<\/a><font size=\-1 color="#3cb371">（.+）<\/font>/KH Coder 3（最新アルファ版）ダウンロード<\/a><font size=\-1 color="#3cb371">（$V_full - $date）<\/font>/;
	
	open(my $fh, ">:encoding(cp932)", "../pub/web/index.html") or die("$!");
	print $fh $t;
	close ($fh);
	
	# en/index.html
	my $r2 = $ua->get('http://khc.sourceforge.net/en/index.html') or die;
	my $t = '';
	$r2->is_success or die;
	$t = $r2->content;
	$t =~ s/\x0D\x0A|\x0D|\x0A/\n/g; # 改行コード

	#$t =~ s/Ver\. 2\.[Bb]eta\.[0-9]+[a-z]*</Ver\. $V_full</;  # バージョン番号
	#$t =~ s/20[0-9]{2} [0-9]{2}\/[0-9]{2}/$date/;             # 日付
	$t =~ s/files\/KH%20Coder\/3\.[Aa]lpha\.[0-9]+\//files\/KH%20Coder\/$V_main\//; # ダウンロードフォルダ
	#
	open(my $fh, '>', "../pub/web/en_index.html") or die;
	print $fh $t;
	close ($fh);
	
	# dl3.html
	my $r1 = $ua->get('http://khc.sourceforge.net/dl3.html') or die;
	$t = '';
	$r1->is_success or die;
	$t = $r1->content;
	$t =~ s/\x0D\x0A|\x0D|\x0A/\n/g; # 改行コード
	
	$t =~ s/\(20[0-9]{2} [0-9]{2}\/[0-9]{2}\)/($date)/g;                 # 日付
	$t =~ s/khcoder\-3a[0-9]+[a-zA-Z]*([\-\.])/khcoder\-$V$1/g;       # ファイル名
	$t =~ s/KH%20Coder\/3\.Alpha\.[0-9]+\//KH%20Coder\/$V_main\//g; # フォルダ名1
	$t =~ s/KH Coder\/3\.Alpha\.[0-9]+\//KH%20Coder\/$V_main\//g; # フォルダ名2


	open(my $fh, '>', "../pub/web/dl3.html") or die;
	print $fh $t;
	close ($fh);
}

sub pdfs{
	# パスワード
	open (my $fh, '<', 'pass.txt') or die;
	my $pass = readline $fh;
	close ($fh);
	undef $fh;

	# Distillerのパス
	system('where acrodist.exe > temp.txt');
	open (my $fh,'<',"temp.txt") or die;
	my $acro_path = readline $fh;
	close $fh;
	unlink("temp.txt");
	chomp $acro_path;
	unless (-e $acro_path){
		die("Could not find Distiller.");
	}

	# 移動
	chdir('..');
	chdir('..');
	chdir('..');
	chdir('doc');
	chdir('tex__phd');
	
	# Distillerの起動
	my $acro_proc;
	Win32::Process::Create(
		$acro_proc,
		$acro_path,
		"acrodist",
		0,
		NORMAL_PRIORITY_CLASS,
		"."
	) or die("Could not start Distiller");
	
	# LaTeX
	system('platex  khcoder_manual_b5');
	system('platex  khcoder_manual_b5');
	system('jbibtex khcoder_manual_b5');
	system('mendex -s dot.ist khcoder_manual_b5');
	system('platex  khcoder_manual_b5');
	system('platex  khcoder_manual_b5');
	
	system('platex  khcoder_tutorial');
	system('platex  khcoder_tutorial');
	system('jbibtex khcoder_tutorial');
	system('platex  khcoder_tutorial');
	system('platex  khcoder_tutorial');
	
	# pdf
	system('dvipdfmx khcoder_manual_b5');
	system('dvipdfmx khcoder_tutorial');

	$acro_proc->Kill(1);
	move('khcoder_manual_b5.pdf', 'khcoder_manual.pdf');

	# security
	system("pdftk khcoder_manual.pdf output out1.pdf owner_pw $pass allow printing screenreaders");
	move('out1.pdf', 'khcoder_manual.pdf');
	system("pdftk khcoder_tutorial.pdf output out2.pdf owner_pw $pass allow printing screenreaders");
	move('out2.pdf', 'khcoder_tutorial.pdf');

	copy ('khcoder_manual.pdf', '../../perl/core/pub/base/win_pkg/khcoder_manual.pdf') or die;
	copy ('khcoder_manual.pdf', '../../perl/core/pub/base/win_upd/khcoder_manual.pdf') or die;
	copy ('khcoder_manual.pdf', '../../perl/core/pub/base/win_strb/khcoder_manual.pdf') or die;
	copy ('khcoder_manual.pdf', '../../perl/core/utils/khcoder_manual.pdf') or die;

	copy ('khcoder_tutorial.pdf', '../../perl/core/pub/base/win_pkg/khcoder_tutorial.pdf') or die;
	copy ('khcoder_tutorial.pdf', '../../perl/core/pub/base/win_upd/khcoder_tutorial.pdf') or die;
	copy ('khcoder_tutorial.pdf', '../../perl/core/pub/base/win_strb/khcoder_tutorial.pdf') or die;
	copy ('khcoder_tutorial.pdf', '../../perl/core/utils/khcoder_tutorial.pdf') or die;

	# 移動
	chdir('..');
	chdir('..');
	chdir('perl');
	chdir('core');
	chdir('utils');

}


sub win_upd{
	chdir("..");
	
	# 新しいファイルを「pub/base/win_upd」へコピー
	foreach my $i (@cp_f){
		copy($i->[0], 'pub/base/win_upd/'.$i->[1]) or die("Can not copy $i\n");
		print "copy: $i->[1]\n";
	}
	
	# Zipファイルを作成
	unlink("utils\\khcoder-$V-s.zip");
	system("wzzip -rp -ex utils\\khcoder-$V-s.zip pub\\base\\win_upd");
	
	chdir("utils");
}

sub win_strb{
	chdir("..");
	
	# khc.plを作成
	open (my $fh, '<', 'utils/kh_coder/kh_coder.pl') or die;
	my $t = do { local $/; <$fh> };
	close $fh;
	
	$t =~ s/\t\tif.*?PerlApp.*?\n/\t\tif (1) {\n/;
	
	open (my $fh, '>', 'pub/base/win_strb/khc.pl') or die;
	print $fh $t;
	close $fh;
	
	# 新しいファイルを「pub/base/win_strb」へコピー（1）strb特有
	rmtree('pub/base/win_strb/kh_lib');
	dircopy('utils/kh_coder/kh_lib', 'pub/base/win_strb/kh_lib');
	shift @cp_f;
	
	# 新しいファイルを「pub/base/win_strb」へコピー（2）共通
	foreach my $i (@cp_f){
		copy($i->[0], 'pub/base/win_strb/'.$i->[1]) or die("Can not copy $i\n");
		print "copy: $i->[1]\n";
	}
	
	# Zipファイルを作成
	unlink("utils\\khcoder-$V-strb.zip");
	system("wzzip -rp -ex utils\\khcoder-$V-strb.zip pub\\base\\win_strb");
	
	chdir("utils");
}


sub win_pkg{
	# 「kh_coder.exe」を作成
	chdir("..");

	#system("svn update");
	unlink("kh_coder.exe");
	system("make_exe.bat");
	unless (-e "kh_coder.exe"){
		die("Could not create \"kh_coder.exe\"\n");
	}
	
	require Win32::API;
	my $win = Win32::API->new(
		'user32.dll',
		'FindWindow',
		'NP',
		'N'
	)->Call(
		0,
		"Console of KH Coder"
	);
	Win32::API->new(
		'user32.dll',
		'ShowWindow',
		'NN',
		'N'
	)->Call(
		$win,
		9
	);
	
	# 新しいファイルを「pub/win_pkg」へコピー
	foreach my $i (@cp_f){
		print "copy: $i->[0]\n";
		copy("$i->[0]", 'pub/win_pkg/'."$i->[1]") or die("Can not copy $i->[0]\n");
	}

	# Zip自己解凍ファイルを作成
	unlink("utils\\khcoder-$V.zip");
	unlink("utils\\khcoder-$V.exe");
	system("wzzip -rp -ex utils\\khcoder-$V.zip pub\\win_pkg");
	sleep 5;
	system("wzipse32 utils\\khcoder-$V.zip -y -d C:\\khcoder3 -le -overwrite -c .\\create_shortcut.exe");
	
	for (my $n = 0; $n < 5; ++$n){
		if (-e "utils\\khcoder-$V.exe" && -e "utils\\khcoder-$V.zip") {
			last;
		}
		sleep 5;
		system("wzipse32 utils\\khcoder-$V.zip -y -d C:\\khcoder3 -le -overwrite -c .\\create_shortcut.exe");
	}

	chdir("utils");
}

sub source_tgz{
	#---------------------------------#
	#   CVSから最新ソースを取り出し   #


	#my $cvs_cmd = 'cvs -d ":ext;command=\'';
	#if (-d $home_dir){
	#	$cvs_cmd .= "set HOME=f:/home/koichi& ";
	#}
	#$cvs_cmd .= "ssh -l ko-ichi ";
	#if (-d $home_dir){
	#	$cvs_cmd .= "-i $key_file ";
	#}
	#$cvs_cmd .= "khc.cvs.sourceforge.net':ko-ichi\@khc.cvs.sourceforge.net:/cvsroot/khc\" ";
	#$cvs_cmd .= "export -r unicode -- core";

	rmtree('core');
	rmtree('kh_coder');

	chdir('..');
	system('git checkout-index -a -f --prefix=utils/core/');
	chdir('utils');

	#--------------------------#
	#   不要なファイルを削除   #

	my @rm_dir = (
		'core/auto_test',
		'core/test',
		'core/utils',
	);

	my @rm_f = (
		'core/memo/bib.html',
		'core/memo/bib.tsv',
		'core/memo/bib_t2h.pl',
		'core/memo/bib_t2h.bat',
		'core/memo/db_memo.csv',
		'core/memo/bib_ng.txt',
		'core/memo/devnote.txt',
		'core/memo/1.icns',
		'core/memo/performance.csv',
		'core/auto_test.pl',
		'core/kh_coder.perlapp',
		'core/make_exe.bat',
		'core/make_exe_as.bat',
		'core/x_mac64.perlapp',
		'core/x_mac64.scpt',
		'core/x_mac64setup.perlapp',
		'core/x_mac64setup.pl',
		'core/x_mac64setup.scpt',
	);

	foreach my $i (@rm_dir){
		rmtree ($i) or warn("warn: could not delete: $i\n");
	}

	foreach my $i (@rm_f){
		unlink ($i) or warn("warn: could not delete: $i\n");
	}

	#---------------------#
	#   ソースZipを作成   #

	unlink("khcoder-$V.tar.gz");

	rename('core', 'kh_coder')
		or warn("warn: could not rename core to kh_coder\n")
	;

	my @files;
	find(
		sub {
			push @files, $File::Find::name;
		},
		"kh_coder"
	);

	my $tar = Archive::Tar->new;
	$tar->add_files(@files);
	$tar->write("khcoder-$V.tar.gz",9);
}