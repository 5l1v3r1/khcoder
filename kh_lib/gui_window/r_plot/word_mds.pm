package gui_window::r_plot::word_mds;
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
	return kh_msg->get('win_title'); # ��и졦¿��������ˡ
}

sub win_name{
	return 'w_word_mds_plot';
}


sub base_name{
	return 'word_mds';
}

1;