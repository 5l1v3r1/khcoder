package gui_window::r_plot::cod_mds;
use base qw(gui_window::r_plot);

sub option1_options{
	return [
		kh_msg->get('gui_window::r_plot::word_corresp->d_l'), # '�ɥåȤȥ�٥�',
		kh_msg->get('gui_window::r_plot::word_corresp->d'), # '�ɥåȤΤ�',
	];
}

sub option1_name{
	return kh_msg->get('gui_window::r_plot::word_corresp->view'); # ' ɽ����';
}

sub win_title{
	return kh_msg->get('win_title'); # �����ǥ��󥰡�¿��������ˡ
}

sub win_name{
	return 'w_cod_mds_plot';
}


sub base_name{
	return 'cod_mds';
}

1;