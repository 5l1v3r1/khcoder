#! /usr/bin/perl

#----------------#
#   ��ޤ�ʸ��   #

use strict;
use vars qw($config_obj $project_obj $main_gui $splash $kh_version);

BEGIN{
	use Cwd qw(cwd);
	push @INC, cwd.'/kh_lib';
}

use mysql_ready;
use mysql_words;
use mysql_conc;
use kh_project;
use kh_projects;
use kh_morpho;
use kh_sysconfig;
use gui_window;

$config_obj = kh_sysconfig->readin('./config/coder.ini',&cwd);
$config_obj->sqllog(0);       # �ǥХå���

#------------------------#
#   �ץ������Ȥ򳫤�   #

kh_project->temp(             # ʬ���оݥե�����Υѥ���DB̾��ľ�ܻ���
	target  =>
		'F:/home/Koichi/Study/perl/CVSS/core/data/big_test/test.html',
#		'E:/home/higuchi/perl/core/data/test_big/test.html',
	dbname  =>
		'khc1',
#		'khc20',
)->open;

# �ƥ��ȥץ���
print "kinds_all: ".mysql_words->num_kinds_all."\n";
print "all: ".mysql_words->num_all."\n";
print "kinds: ".mysql_words->num_kinds."\n\n";

#----------------#
#   �ƥ��Ƚ���   #

use Benchmark;                                    # ���ַ�¬��
my $t0 = new Benchmark;                           # ���ַ�¬��

# �����¹�
my $result = mysql_conc->a_word(
	query   => '�Ȥ�',
	kihon   => 1,
	length => 15,
	sort1   => "l1",
	sort2   => "l2",
	sort3   => "l3",
);

my $t1 = new Benchmark;                           # ���ַ�¬��
print timestr(timediff($t1,$t0)),"\n";            # ���ַ�¬��

# ��̤����
open (OUT,">test.txt");
foreach my $i (@{$result}){
	print OUT "$i->[0]  $i->[1]  $i->[2]\n";
}

