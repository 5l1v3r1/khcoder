package gui_window::r_plot::word_corresp;
use base qw(gui_window::r_plot);

sub option1_options{
	my $self = shift;

	if (@{$self->{plots}} == 2){
		return [
			'�ɥåȤȥ�٥�',
			'�ɥåȤΤ�',
		] ;
	} else {
		return [
			'���顼',
			'���졼��������',
			'�ѿ��Τ�',
			'�ɥåȤΤ�',
		] ;
	}
}

sub option1_name{
	return ' ɽ����';
}

sub win_title{
	return '��и졦�б�ʬ��';
}

sub win_name{
	return 'w_word_corresp_plot';
}

sub base_name{
	return 'word_corresp';
}

1;