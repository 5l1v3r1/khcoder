package gui_window::cod_out::csv;
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
		[ "csv file",[qw/.csv/] ],
		["All files",'*']
	);
	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.csv',
		-filetypes        => \@types,
		-title            =>
			Jcode->new('�R�[�f�B���O���ʁiCSV�j�F���O��t���ĕۑ�')->sjis,
		-initialdir       => $::config_obj->cwd
	);
	
	# �ۑ������s
	if ($path){
		my $result;
		unless ( $result = kh_cod::func->read_file($self->cfile) ){
			return 0;
		}
		$result->cod_out_csv($self->tani,$path);
	}
	
	$self->close;
}

sub win_label{
	return '�R�[�f�B���O���ʂ̏o�́FCSV�t�@�C��';
}

sub win_name{
	return 'w_cod_save_csv';
}
1;