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
		max2    => $self->max2,
		min2    => $self->min2,
		hinshi  => $self->hinshi,
		max     => $self->max,
		min     => $self->min,
	)->culc->save($file);
	
}

#-----------------#
#   ��¸��λ���  #

sub file_name{
	my $self = shift;
	my @types = (
		[ Jcode->new("���ֶ��ڤ�")->sjis,[qw/.txt/] ],
		["All files",'*']
	);
	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.txt',
		-filetypes        => \@types,
		-title            =>
			Jcode->new('����и��ʸ̮�٥��ȥ��ɽ��̾�����դ�����¸')->sjis,
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
