#!/usr/local/bin/perl

=head1 COPYRIGHT

Copyright (C) 2008 ����k�� <http://koichi.nihon.to/psnl>

�{�v���O�����̓t���[�E�\�t�g�E�F�A�ł��B

���Ȃ��́AFree Software Foundation �����\����GNU��ʌ��L�g�p�������iThe GNU General Public License�j�́u�o�[�W����2�v�����͂���ȍ~�̊e�o�[�W�����̒����炢���ꂩ��I�����A���̃o�[�W��������߂�����ɏ]���Ė{�v���O�������g�p�A�ĔЕz�A�܂��͕ύX���邱�Ƃ��ł��܂��B

�{�v���O�����͗L�p�Ƃ͎v���܂����A�Еz�ɓ������ẮA�s�ꐫ�y�ѓ���ړI�K�����ɂ��Ă̈Öق̕ۏ؂��܂߂āA�����Ȃ�ۏ؂��s���܂���B

�ڍׂɂ��Ă�GNU��ʌ��L�g�p�����������ǂ݉������BGNU��ʌ��L�g�p�������͖{�v���O�����̃}�j���A���̖����ɓY�t����Ă��܂��B���邢��<http://www.gnu.org/licenses/>�ł��AGNU��ʌ��L�g�p���������{�����邱�Ƃ��ł��܂��B

=cut

use strict;
use vars qw($config_obj $project_obj $main_gui $splash $kh_version);

BEGIN {
	$kh_version = "2.beta.12";
	use Cwd qw(cwd);
	use lib cwd.'/kh_lib';
	use lib cwd.'/plugin';
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

# Windows�Ńp�b�P�[�W�p�̏�����
if (
	   ($::config_obj->os eq 'win32')
	&& $::config_obj->all_in_one_pack
){
	use kh_all_in_one;
	kh_all_in_one->init;
}

# R�̏�����
use Statistics::R;
$::config_obj->{R} = Statistics::R->new(
	log_dir => $::config_obj->{cwd}.'/config/R-bridge'
);
if ($::config_obj->{R}){
	$::config_obj->{R}->startR;
	$::config_obj->{R}->output_chk(1);
} else {
	$::config_obj->{R} = 0;
}
chdir ($::config_obj->{cwd});

$main_gui = gui_window::main->open;
MainLoop;

#-----------------#
#   for PerlApp   #

use Tk::DragDrop::Win32Drop;
use Tk::DragDrop::Win32Site;
use SQL::Dialects::CSV;
