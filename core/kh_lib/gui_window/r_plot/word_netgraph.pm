package gui_window::r_plot::word_netgraph;
use base qw(gui_window::r_plot);

sub option1_options{
	my $self = shift;
	
	if (@{$self->{plots}} == 2){
		return [
			'���顼',
			'���졼��������',
		] ;
	} else {
		return [
			'�濴�����޲��',
			'�濴���ʼ�����',
			'���֥���ո��С��޲��',
			'���֥���ո��С�modularity��',
			'�ʤ�',
		];
	}

}

sub option1_name{
	return ' ���顼��';
}

sub win_title{
	return '��и졦�����ͥåȥ��';
}

sub win_name{
	return 'w_word_netgraph_plot';
}


sub base_name{
	return 'word_netgraph';
}

1;