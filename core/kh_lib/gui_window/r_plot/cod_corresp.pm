package gui_window::r_plot::cod_corresp;
use base qw(gui_window::r_plot);

sub option1_options{
	my $self = shift;

	if (@{$self->{plots}} == 2){
		return [
			'��и�ȥɥå�',
			'�ɥå�',
		] ;
	} else {
		return [
			'��и�ȥɥå�',
			'��и�ȥɥåȡʥ��졼��',
			'�ɥå�',
		] ;
	}
}

sub option1_name{
	return ' ɽ����';
}

sub win_title{
	return '�����ǥ��󥰡��б�ʬ��';
}

sub win_name{
	return 'w_cod_corresp_plot';
}

sub base_name{
	return 'cod_corresp';
}

1;