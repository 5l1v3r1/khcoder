package gui_window::cod_out::tab;
use base qw(gui_window::cod_out);

use strict;

sub _save{
	my $self = shift;
	
	unless (-e $self->cfile){
		my $win = $self->win_obj;
		gui_errormsg->open(
			msg => "�����ǥ��󥰡��롼�롦�ե����뤬���򤵤�Ƥ��ޤ���",
			window => \$win,
			type => 'msg',
		);
		return;
	}
	
	# ��¸��λ���
	my @types = (
		[ Jcode->new("���ֶ��ڤ�")->sjis,[qw/.txt/] ],
		["All files",'*']
	);
	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.txt',
		-filetypes        => \@types,
		-title            =>
			Jcode->new('�����ǥ��󥰷�̡�̾�����դ�����¸')->sjis,
		-initialdir       => $::config_obj->cwd
	);
	
	# ��¸��¹�
	if ($path){
		my $result;
		unless ( $result = kh_cod::func->read_file($self->cfile) ){
			return 0;
		}
		$result->cod_out_tab($self->tani,$path);
	}
	
	$self->close;
}

sub win_label{
	return '�����ǥ��󥰷�̤ν��ϡ� ���ֶ��ڤ�';
}

sub win_name{
	return 'w_cod_save_tab';
}
1;