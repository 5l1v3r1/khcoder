package gui_window::r_plot::word_corresp;
use base qw(gui_window::r_plot);

sub option1_options{
	my $self = shift;

	if (@{$self->{plots}} == 2){
		return [
			kh_msg->get('d_l'), # �ɥåȤȥ�٥�
			kh_msg->get('d'), # �ɥåȤΤ�
		] ;
	} else {
		return [
			kh_msg->get('col'), # ���顼
			kh_msg->get('gray'), # ���졼��������
			kh_msg->get('var'), # �ѿ��Τ�
			kh_msg->get('d'), # �ɥåȤΤ�
		] ;
	}
}

sub option1_name{
	return kh_msg->get('view'); #  ɽ����
}

sub win_title{
	return kh_msg->get('win_title'); # ��и졦�б�ʬ��
}

sub win_name{
	return 'w_word_corresp_plot';
}

sub base_name{
	return 'word_corresp';
}

1;