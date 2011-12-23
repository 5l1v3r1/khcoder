package gui_window::r_plot::selected_netgraph;
use base qw(gui_window::r_plot);

sub option1_options{
	return [
		kh_msg->gget('r_net_col_cnt_b'), # �濴�����޲��
		kh_msg->gget('r_net_col_cnt_d'), # �濴���ʼ�����
		kh_msg->gget('r_net_col_cnt_v'), # �濴���ʸ�ͭ�٥��ȥ��
		kh_msg->gget('r_net_col_com_b'), # ���֥���ո��С��޲��
		kh_msg->gget('r_net_col_com_m'), # ���֥���ո��С�modularity��
		kh_msg->gget('r_net_col_none'),  # �ʤ�
	];
}

sub option1_name{
	return kh_msg->get('color'); #  ���顼��
}

sub win_title{
	return kh_msg->get('win_title'); # ��Ϣ�졦�����ͥåȥ��
}

sub win_name{
	return 'w_selected_netgraph_plot';
}


sub base_name{
	return 'selected_netgraph';
}

1;