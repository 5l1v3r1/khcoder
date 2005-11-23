package gui_window::contxt_out::tab;
use base qw(gui_window::contxt_out);

use strict;

#--------------#
#   ���å�   #
#--------------#

sub go{
	print "go!";
	
	my $self = shift;
	my $file = shift;
	
	mysql_contxt::tab->new(
		tani    => $self->{tani_obj}->value,
		hinshi2 => $self->hinshi2,
		max2    => $self->gui_jg( $self->max2 ),
		min2    => $self->gui_jg( $self->min2 ),
		hinshi  => $self->hinshi,
		max     => $self->gui_jg( $self->max ),
		min     => $self->gui_jg( $self->min ),
	)->culc->save($file);
}

#-----------------#
#   ��¸��λ���  #

sub file_name{
	my $self = shift;
	my @types = (
		[ $self->gui_jchar("���ֶ��ڤ�"),[qw/.txt/] ],
		["All files",'*']
	);
	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.txt',
		-filetypes        => \@types,
		-title            =>
			$self->gui_jchar('����и��ʸ̮�٥��ȥ��ɽ��̾�����դ�����¸'),
		-initialdir       => $::config_obj->cwd
	);
	unless ($path){
		return 0;
	}
	return $path;
}

# Window��٥�
sub label{
	return '����и��ʸ̮�٥��ȥ��ɽ�ν��ϡ� ���ֶ��ڤ�';
}

sub win_name{
	return 'w_cross_out_tab';
}

1;
