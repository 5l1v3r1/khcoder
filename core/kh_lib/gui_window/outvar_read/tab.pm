package gui_window::outvar_read::tab;
use base qw(gui_window::outvar_read);
use strict;
use Jcode;

use mysql_outvar::read;

#------------------#
#   �t�@�C���Q��   #
#------------------#

sub file{
	my $self = shift;

	my @types = (
		[ Jcode->new("�^�u��؂�t�@�C��")->sjis,[qw/.dat .txt/] ],
		["All files",'*']
	);
	
	my $path = $self->win_obj->getOpenFile(
		-filetypes  => \@types,
		-title      => Jcode->new('�O���ϐ��t�@�C����I�����Ă�������')->sjis,
		-initialdir => $::config_obj->cwd
	);
	
	if ($path){
		$self->{entry}->delete(0, 'end');
		$self->{entry}->insert('0',Jcode->new("$path")->sjis);
	}
}

#--------------#
#   �ǂݍ���   #
#--------------#

sub __read{
	my $self = shift;

	return mysql_outvar::read::tab->new(
		file => $self->{entry}->get,
		tani => $self->{tani_obj}->tani,
	)->read;
}

#--------------#
#   �A�N�Z�T   #
#--------------#

sub file_label{
	Jcode->new('�^�u��؂�t�@�C��')->sjis;
}

sub win_title{
	return Jcode->new('�O���ϐ��̓ǂݍ��݁F �^�u��؂�')->sjis;
}

sub win_name{
	return 'w_outvar_read_tab';
}

1;