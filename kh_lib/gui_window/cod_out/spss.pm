package gui_window::cod_out::spss;
use base qw(gui_window::cod_out);

use strict;

sub _save{
	my $self = shift;
	
	unless (-e $self->cfile){
		my $win = $self->win_obj;
		gui_errormsg->open(
			msg => "�R�[�f�B���O�E���[���E�t�@�C�����I������Ă��܂���B",
			window => \$win,
			type => 'msg',
		);
		return;
	}
	
	# �ۑ���̎Q��
	my @types = (
		[ "csv file",[qw/.sps/] ],
		["All files",'*']
	);
	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.sps',
		-filetypes        => \@types,
		-title            =>
			Jcode->new('�R�[�f�B���O���ʁiSPSS�j�F���O��t���ĕۑ�')->sjis,
		-initialdir       => $::config_obj->cwd
	);
	
	# �ۑ������s
	if ($path){
		my $result;
		unless ( $result = kh_cod::func->read_file($self->cfile) ){
			return 0;
		}
		$result->cod_out_spss($self->tani,$path);
	}
	
	$self->close;
}



sub win_label{
	return '�R�[�f�B���O���ʂ̏o�́FSPSS�t�@�C��';
}

sub win_name{
	return 'w_cod_save_spss';
}
1;