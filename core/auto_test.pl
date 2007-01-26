#!/usr/local/bin/perl

use strict;
use vars qw($config_obj $project_obj $main_gui $splash $kh_version);

BEGIN {
	$kh_version = "2.x Tester";
	use Cwd qw(cwd);
	use lib cwd.'/kh_lib';
	if ($^O eq 'MSWin32'){
		require Tk::Splash;
		$splash = Tk::Splash->Show(
			Tk->findINC('kh_logo.bmp'),
			400,
			109,
			'',
		);
	} else {
		push @INC, cwd.'/dummy_lib';
	}
	
	use kh_sysconfig;
	$config_obj = kh_sysconfig->readin('./config/coder.ini',&cwd);
}

use Tk;

use mysql_ready;
use mysql_words;
use mysql_conc;
use kh_project;
use kh_projects;
use kh_morpho;
use gui_window;

$main_gui = gui_window::main->open;

#--------------------#
#   �e�X�g�p�R�[�h   #

use Cwd qw(cwd);
use lib cwd.'/auto_test/lib';
use kh_at;
use Benchmark;

my $t0 = new Benchmark;

kh_at::project_new->exec_test('project_new');      # �e�X�g�t�@�C���o�^&�O����
#kh_at->open_test_project;

kh_at::pretreatment->exec_test('pretreatment');    # �O�������j���[
kh_at::words->exec_test('words');                  # ���o�ꃁ�j���[
kh_at::out_var->exec_test('out_var');              # �O���ϐ����j���[


kh_at->close_test_project;                         # �v���W�F�N�g�����
#kh_at->delete_test_project;                        # �v���W�F�N�g���폜

my $t1 = new Benchmark;
print "\nAll Done! ",timestr(timediff($t1,$t0)),"\n";


MainLoop;
