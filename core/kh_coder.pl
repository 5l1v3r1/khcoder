#!/usr/local/bin/perl

=head1 COPYRIGHT

Copyright (C) 2008 �����̰� <http://koichi.nihon.to/psnl>

�ܥץ����ϥե꡼�����եȥ������Ǥ���

���ʤ��ϡ�Free Software Foundation ����ɽ����GNU���̸�ͭ���ѵ������The GNU General Public License�ˤΡ֥С������2�װ����Ϥ���ʹߤγƥС��������椫�餤���줫�����򤷡����ΥС������������˽��ä��ܥץ�������ѡ������ۡ��ޤ����ѹ����뤳�Ȥ��Ǥ��ޤ���

�ܥץ�����ͭ�ѤȤϻפ��ޤ��������ۤ������äƤϡ��Ծ����ڤ�������ŪŬ�����ˤĤ��Ƥΰ��ۤ��ݾڤ�ޤ�ơ������ʤ��ݾڤ�Ԥ��ޤ���

�ܺ٤ˤĤ��Ƥ�GNU���̸�ͭ���ѵ�������ɤ߲�������GNU���̸�ͭ���ѵ�������ܥץ����Υޥ˥奢���������ź�դ���Ƥ��ޤ������뤤��<http://www.gnu.org/licenses/>�Ǥ⡢GNU���̸�ͭ���ѵ������������뤳�Ȥ��Ǥ��ޤ���

=cut

use strict;
#use warnings;
use Cwd;
use vars qw($config_obj $project_obj $main_gui $splash $kh_version);

$kh_version = "2.beta.12";

BEGIN {
	# for Windows [1]
	if ($^O eq 'MSWin32'){
		# Cwd.pm�ξ��
		no warnings 'redefine';
		sub Cwd::_win32_cwd {
			if (defined &DynaLoader::boot_DynaLoader) {
				$ENV{'PWD'} = Win32::GetCwd();
			}
			else { # miniperl
				chomp($ENV{'PWD'} = `cd`);
			}
			use Jcode;
			$ENV{'PWD'} = Jcode->new($ENV{'PWD'},'sjis')->euc;
			$ENV{'PWD'} =~ s:\\:/:g ;
			$ENV{'PWD'} = Jcode->new($ENV{'PWD'},'euc')->sjis;
			#print "hoge\n";
			return $ENV{'PWD'};
		};
		*cwd = *Cwd::cwd = *Cwd::getcwd = *Cwd::fastcwd = *Cwd::fastgetcwd = *Cwd::_NT_cwd = \&Cwd::_win32_cwd;
		use warnings 'redefine';
	}

	# �⥸�塼��Υѥ����ɲ�
	push @INC, cwd.'/kh_lib';
	push @INC, cwd.'/plugin';

	# for Windows [2]
	if ($^O eq 'MSWin32'){
		# ���󥽡����Ǿ���
		require Win32::Console;
		Win32::Console->new->Title('Console of KH Coder');
		if (defined($PerlApp::VERSION) && substr($PerlApp::VERSION,0,1) >= 7 ){
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
				2
			);
		}
		# ���ץ�å���
		require Tk::Splash;
		$splash = Tk::Splash->Show(
			Tk->findINC('kh_logo.bmp'),
			400,
			109,
			'',
		);
	} 
	# for Linux & Others
	else {
		push @INC, cwd.'/dummy_lib';
		if ($] > 5.008){
			require Tk::FBox;
			require Tk::FBox_kh;
		}
	}

	# ������ɤ߹���
	require kh_sysconfig;
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

# Windows�ǥѥå������Ѥν����
if (
	   ($::config_obj->os eq 'win32')
	&& $::config_obj->all_in_one_pack
){
	use kh_all_in_one;
	kh_all_in_one->init;
}

# R�ν����
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


# GUI�γ���
$main_gui = gui_window::main->open;
MainLoop;

__END__

# �ƥ����ѥץ������Ȥ򳫤�
kh_project->temp(
	target  =>
		'F:/home/Koichi/Study/perl/test_data/kokoro/kokoro.txt',
	dbname  =>
		'khc4',
)->open;
$::main_gui->close_all;
$::main_gui->menu->refresh;
$::main_gui->inner->refresh;

# ����Ρʥƥ����ѡ�Window�򳫤�
gui_window::word_ass->open;

MainLoop;
