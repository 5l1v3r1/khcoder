package sample2_hello_world_file;  # �����ιԤϥե�����̾�ˤ��碌���ѹ�
use strict;                        # ���ե������ʸ�������ɤ�EUC��侩

#--------------------------#
#   ���Υץ饰���������   #

sub plugin_config{
	return {
		name     => 'Hello World - �ե�����',        # ��˥塼��ɽ�������̾��
		menu_cnf => 1,                               # ��˥塼������(1)
			# 0: ���ĤǤ�¹Բ�ǽ
			# 1: �ץ������Ȥ�������Ƥ�������м¹Բ�ǽ
			# 2: �ץ������Ȥ�������������äƤ���м¹Բ�ǽ
		menu_grp => '����ץ�',                      # ��˥塼������(2)
			# ��˥塼�򥰥롼�ײ����������ˤ��������Ԥ���
			# ɬ�פʤ����ϡ�'',�פޤ��ϡ�undef,�פȤ��Ƥ������ɤ���
	};
}

#----------------------------------------#
#   ��˥塼������˼¹Ԥ����롼����   #

sub exec{

	#-----------------------------------#
	#   GUI�ǽ�����Υե�����̾�����   #

	my $mw = $::main_gui->mw;           # KH Coder�Υᥤ�󡦥�����ɥ������

	my $path = $mw->getSaveFile(        # Tk�Υե����������������
		-title            => gui_window->gui_jchar('��å���������¸'),
		-initialdir       => $::config_obj->cwd,
		-defaultextension => '.txt',
		-filetypes        => [
			[ gui_window->gui_jchar("�ƥ�����"),'.txt' ],
			["All files",'*']
		]
	);
		# gui_window->gui_jchar('ʸ����')�ǡ�ʸ�������ɤ�GUI�Ѥ��Ѵ�
		# $::config_obj->cwd�ǡ�KH Coder��¸�ߤ���ǥ��쥯�ȥ������

	return 0 unless length($path);

	#------------------------------#
	#   ���Ϥ����å����������   #

	my $msg = '';
	$msg .= 'ʬ���оݥե����롧 ';
	$msg .= $::project_obj->file_target;
	$msg .= "\n";
	$msg .= '��⡧ ';
	$msg .= $::project_obj->comment;
	$msg .= "\n";
	$msg .= '�������� ';

	if ( $::project_obj->status_morpho ){
		$msg .= '�¹ԺѤ�'
	} else {
		$msg .= '̤�¹�'
	}

	$msg .= "\n\n";
	$msg .= '��KH Coder�Υ���ץ롦�ץ饰����ˤ��ƥ��Ƚ���';

	#----------------------#
	#   �ե�����ؤν���   #

	open (SMPLOUT,">$path") or          # �ե�����򥪡��ץ�
		gui_errormsg->open(             # �����ץ��Ի��Υ��顼ɽ��
			type => 'file',
			thefile => $path
		);

	print SMPLOUT $msg;                 # �ե�����ؽ񤭽Ф�

	close (SMPLOUT);                    # �ե�����Υ�����

	#--------------------#
	#   ��ǧ���̤�ɽ��   #
	
	gui_window::sample_hello_world2_file->open(
		msg  => $msg,
		path => $path,
	);
	
	return 1;
}

#------------------------------#
#   ��ǧ����ɽ���ѤΥ롼����   #

package gui_window::sample_hello_world2_file; # �����ιԤϡ�gui_window::�פǻ�
use base qw(gui_window);                      #           �ޤ�Ŭ����̾�Τ��ѹ�
use strict;
use Tk;

## Window�κ���
sub _new{
	# �ѿ��μ���
	my $self = shift;
	my %args = @_;
	my $mw = $self->win_obj; # Window��Tk���֥������ȡˤ��������$mw�˳�Ǽ

	# Window�Υ����ȥ������
	$mw->title( gui_window->gui_jchar('����ץ롧Hello World�ʥե������') );

	# ��٥��ɽ��(0)
	$mw->Label(
		-text => gui_window->gui_jchar(' ���ե�����ؤν��Ϥ���λ���ޤ���'),
	)->pack(
		-anchor => 'w',
		-pady => 5
	);

	# ��٥��ɽ��(1)
	$mw->Label(
		-text => gui_window->gui_jchar(' ���ϥե����롧 '.$args{path},'euc'),
	)->pack(-anchor => 'w');

	# ��٥��ɽ��(2)
	$mw->Label(
		-text => gui_window->gui_jchar(' �������ơ�'),
	)->pack(
		-anchor => 'w'
	);

	# �ƥ����ȥե�����ɡ�Read Only�ˤ�ɽ��
	my $text_widget = $mw->Scrolled(
		"ROText",
		-scrollbars => 'osoe',
		-height     => 5,
		-width      => 64,
	)->pack(
		-padx   => 2,
		-fill   => 'both',
		-expand => 'yes'
	);
	$text_widget->bind("<Key>",[\&gui_jchar::check_key,Ev('K'),\$text_widget]);

	# �ƥ����ȥե�����ɤ˥�å�����������
	$text_widget->insert(
		'end',
		gui_window->gui_jchar( $args{msg} )
	);

	# ���Ĥ���ץܥ����ɽ��
	$mw->Button(
		-text    => gui_window->gui_jchar('�Ĥ���'),
		-command => sub{ $self->close; }
	)->pack(
		-pady => 2
	)->focus;

	return $self;
}

## Window��̾�Τ�����
sub win_name{                 
	return 'w_sample_hello_world2_file'; # �����ιԤϡ�w_�פǻϤޤ�Ŭ����̾��
}	                                     #                             ���ѹ�

1;
