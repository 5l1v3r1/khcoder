package gui_window::r_plot::cod_netg;
use base qw(gui_window::r_plot);

sub option1_options{
	return [
		'�濴�����޲��',
		'�濴���ʼ�����',
		'�濴���ʸ�ͭ�٥��ȥ��',
		'���֥���ո��С��޲��',
		'���֥���ո��С�modularity��',
		'�ʤ�',
	];
}

sub option1_name{
	return ' ���顼��';
}

sub win_title{
	return '�����ǥ��󥰡������ͥåȥ��';
}

sub win_name{
	return 'w_cod_netg_plot';
}


sub base_name{
	return 'cod_netg';
}

1;