# ���ޥ�ɥ饤�󤫤��kh_coder.exe -auto_run �ƥ����ȥե�����̾�פΤ褦�˵�ư
# ����ȡ����ꤵ�줿�ƥ����ȥե����뤫�鶦���ͥåȥ�����������ץ饰����
# ���������ꤷ���ե����뤬���Ǥ˥ץ������ȤȤ�����Ͽ����Ƥ���ȡ��¹Ԥ˼���
# ���롣�ޤ��ե�����̾�ϥե�ѥ��ǻ��ꡣkh_coder.exe��Ʊ�����򥫥��ȥǥ���
# ���ȥ�Ȥ��Ƽ¹Ԥ��롣

# ��Ω���ǤΡ�Useful R�ץ��꡼����10����R�Υѥå���������ӥġ���κ����ȱ��ѡ�
# ���ܥץ饰����β��⤬����ޤ���http://amzn.to/2AYS5dI

# �ץ饰���������
package auto_run;

sub plugin_config{

	# ��ư������Ԥ����ɤ���Ƚ��
	if ( defined($ARGV[0]) && defined($ARGV[1]) && $ARGV[0] eq '-auto_run' && -e $ARGV[1] ){
		
		# �ե�����̾����
		my $file_target = $ARGV[1];
		my $file_save   = 'net.png';

		# �ץ������ȿ�������
		my $new = kh_project->new(
		    target => $file_target,
		    comment => 'auto',
		) or die("could not create a project\n");
		kh_projects->read->add_new($new) or die("could not save the project\n");

		# �������������ץ������Ȥ򳫤�
		$new->open or die("could not open the project\n");
		$::project_obj->morpho_analyzer_lang( 'jp' );
		$::project_obj->morpho_analyzer( 'chasen' );

		# �������¹�
		my $wait_window = gui_wait->start;
		&gui_window::main::menu::mc_morpho_exec;
		$wait_window->end(no_dialog => 1);

		# �����ͥåȥ������
		my $win = gui_window::word_netgraph->open;
		$win->{net_obj}->{entry_edges_number}->delete('0','end'); # �������120��
		$win->{net_obj}->{entry_edges_number}->insert('end','120');
		$win->{net_obj}->{check_use_freq_as_size} = 1; # �и�����¿���ۤ��礭��
		$win->calc;

		# �����ͥåȥ����¸
		my $win_result = $::main_gui->get('w_word_netgraph_plot');
		$win_result->{plots}[2]->save($file_save); # 3���ܤΥץ�åȤ���¸

		# �ץ������Ȥ��Ĥ���
		$::main_gui->close_all;
		undef $::project_obj;

		# �ץ������Ȥ���
		#�ʺǸ���ɲä����ץ������Ȥκ����
		my $win_opn = gui_window::project_open->open;
		my $n = @{$win_opn->projects->list} - 1;
		$win_opn->{g_list}->selectionClear(0);
		$win_opn->{g_list}->selectionSet($n);
		$win_opn->delete;
		$win_opn->close;

		# KH Coder��λ
		exit;
	
	}

	return undef;
}

1;
