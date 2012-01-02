package gui_window::r_plot::word_netgraph;
use base qw(gui_window::r_plot);

sub option1_options{
	my $self = shift;
	
	if (@{$self->{plots}} == 2){
		return [
			kh_msg->get('gui_window::r_plot::word_netgraph->col'), # ���顼
			kh_msg->get('gui_window::r_plot::word_netgraph->gray'), # ���졼
		] ;
	} else {
		return [
			kh_msg->get('gui_window::r_plot::word_netgraph->cnt_b'), # �濴�����޲��
			kh_msg->get('gui_window::r_plot::word_netgraph->cnt_d'), # �濴���ʼ�����
			kh_msg->get('gui_window::r_plot::word_netgraph->cnt_v'), # �濴���ʸ�ͭ�٥��ȥ��
			kh_msg->get('gui_window::r_plot::word_netgraph->com_b'), # ���֥���ո��С��޲��
			kh_msg->get('gui_window::r_plot::word_netgraph->com_m'), # ���֥���ո��С�modularity��
			kh_msg->get('gui_window::r_plot::word_netgraph->none'),  # �ʤ�
		];
	}

}

sub option1_name{
	return kh_msg->get('gui_window::r_plot::word_netgraph->color'); #  ���顼��
}

sub win_title{
	return kh_msg->get('win_title'); # ��и졦�����ͥåȥ��
}

sub win_name{
	return 'w_word_netgraph_plot';
}


sub base_name{
	return 'word_netgraph';
}

1;