package gui_window::r_plot::word_som;
use base qw(gui_window::r_plot);

sub option1_options{
	my $self = shift;
	if (@{$self->{plots}} == 2){
		return [
			kh_msg->get('gui_window::r_plot::word_corresp->col'),  # ���顼
			kh_msg->get('gui_window::r_plot::word_corresp->gray'), # ���졼
		];
	} else {
		return [
			kh_msg->get('gui_window::r_plot::word_corresp->gray'), # ���졼
		];
	}
}

sub option1_name{
	return kh_msg->get('gui_window::r_plot::word_corresp->view'); # ' ɽ����';
}

sub win_title{
	return kh_msg->get('win_title'); # ��и졦�����ȿ����ޥå�
}

sub win_name{
	return 'w_word_som_plot';
}


sub base_name{
	return 'word_som';
}

1;