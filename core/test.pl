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

#------------------------#
#   �ץ������Ȥ򳫤�   #

kh_project->temp(             # ʬ���оݥե�����Υѥ���DB̾��ľ�ܻ���
	target  =>
		'F:/home/Koichi/Study/perl/CVSS/core/data/big_test/inet_and_hp.html',
	dbname  => 'khc36',
)->open;

# �ƥ��ȥץ���
print "kinds_all: ".mysql_words->num_kinds_all."\n";
print "all: ".mysql_words->num_all."\n";
print "kinds: ".mysql_words->num_kinds."\n\n";

#----------------#
#   �ƥ��Ƚ���   #

use Benchmark;                                    # ���ַ�¬��
my $t0 = new Benchmark;                           # ���ַ�¬��

my $result = mysql_conc->a_word(
	query  => '��',
	kihon => '1'
);

my $t1 = new Benchmark;                           # ���ַ�¬��
print timestr(timediff($t1,$t0)),"\n";            # ���ַ�¬��

open (OUT,">test.txt");
foreach my $i (@{$result}){
	print OUT "$i->[0]  $i->[1]  $i->[2]\n";
}

