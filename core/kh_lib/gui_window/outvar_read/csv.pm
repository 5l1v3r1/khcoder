package gui_window::outvar_read::csv;
use base qw(gui_window::outvar_read);
use strict;
use Jcode;

use mysql_outvar::read;

#------------------#
#   �ե����뻲��   #
#------------------#

sub file{
	my $self = shift;

	my @types = (
		[ $self->gui_jchar("CSV�ե�����"),[qw/.csv/] ],
		["All files",'*']
	);
	
	my $path = $self->win_obj->getOpenFile(
		-filetypes  => \@types,
		-title      => $self->gui_jchar('�����ѿ��ե���������򤷤Ƥ�������'),
		-initialdir => $::config_obj->cwd
	);
	
	if ($path){
		$self->{entry}->delete(0, 'end');
		$self->{entry}->insert('0',$self->gui_jchar("$path"));
	}
}

#--------------#
#   �ɤ߹���   #
#--------------#

sub __read{
	my $self = shift;
	
	return mysql_outvar::read::csv->new(
		file => $self->{entry}->get,
		tani => $self->{tani_obj}->tani,
	)->read;
}

#--------------#
#   ��������   #
#--------------#

sub file_label{
	my $self = shift;
	$self->gui_jchar('CSV�ե�����');
}

sub win_title{
	my $self = shift;
	return $self->gui_jchar('�����ѿ����ɤ߹��ߡ� CSV�ե�����');
}

sub win_name{
	return 'w_outvar_read_csv';
}

1;