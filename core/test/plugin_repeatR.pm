# �Ǿ��¡ʤ˶ᤤ�˥ץ饰������

package p1_sample5_repeatR;

sub plugin_config{
	return {
		name     => '�����ͥåȥ����Ĵ���򷫤��֤�',
		menu_grp => '����ץ�',         # ���ιԤϡ�����ϡ˾�ά��
	};
}

sub exec{
	print "short sample\n";             # ������ɬ�פʽ������Ƥ򵭽�

	# �����ͥåȥ���Ρ�Ĵ���פ򷫤��֤�
	my $n = 0;
	while (1){
		my $c = $::main_gui->get('w_word_netgraph_plot');

		my $cc = gui_window::r_plot_opt::word_netgraph->open(
			command_f => $c->{plots}[$c->{ax}]->command_f,
			size      => $c->original_plot_size,
		);
		
		my $en = 100 + int( rand(50) );
		$cc->{net_obj}->{entry_edges_number}->delete(0,'end');
		$cc->{net_obj}->{entry_edges_number}->insert(0,$en);
		
		$cc->calc;
		
		++$n;
		print "#### $n ####\n";
		
		my $sn = int(rand(5));
		#sleep $sn;
	}

}

1;                                      # �����˺�줺�ˡġ�
