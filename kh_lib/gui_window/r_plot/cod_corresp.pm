package gui_window::r_plot::cod_corresp;
use base qw(gui_window::r_plot);

sub option1_options{
	my $self = shift;

	if (@{$self->{plots}} == 2){
		return [
			kh_msg->get('gui_window::r_plot::word_corresp->d_l'), # �ɥåȤȥ�٥�
			kh_msg->get('gui_window::r_plot::word_corresp->d'), # �ɥåȤΤ�
		] ;
	} else {
		return [
			kh_msg->get('gui_window::r_plot::word_corresp->col'), # ���顼
			kh_msg->get('gui_window::r_plot::word_corresp->gray'), # ���졼��������
			kh_msg->get('gui_window::r_plot::word_corresp->var'), # �ѿ��Τ�
			kh_msg->get('gui_window::r_plot::word_corresp->d'), # �ɥåȤΤ�
		] ;
	}
}

sub extra_save_types{
	return (
		[ "CSV",[qw/.csv/] ],
	);
}

sub option1_name{
	return kh_msg->get('gui_window::r_plot::word_corresp->view'); #  ɽ����
}

sub win_title{
	return kh_msg->get('win_title'); # �����ǥ��󥰡��б�ʬ��
}

sub win_name{
	return 'w_cod_corresp_plot';
}

sub base_name{
	return 'cod_corresp';
}

1;