package gui_window::use_te;
use base qw(gui_window);

sub _new{
	my $self = shift;
	$self->{win_obj}->title($self->gui_jchar('TermExtract������ˤĤ���','euc'));;

	$self->{win_obj}->Label(
		-text => $self->gui_jchar('�����Ѹ�ʥ�����ɡ˼�ư�����Perl�⥸�塼��"TermExtract"�����Ѥ��ޤ���','euc'),
		-font => "TKFN",
	)->pack(-anchor => 'w',-pady=>'2',-padx=>'2');
	$self->{win_obj}->Label(
		-text => $self->gui_jchar('TermExtract������ˤĤ��Ƥϰʲ�������������','euc'),
		-font => "TKFN",
	)->pack(-anchor => 'w',-pady=>'2',-padx=>'2');



	my $f1 = $self->{win_obj}->Frame()->pack();
	
	$f1->Label(
		-text => $self->gui_jchar('TermExtract��Web�ڡ�����','euc'),
		-font => "TKFN",
	)->pack(-anchor => 'w',-pady=>'2',-padx=>'2', side => 'left');

	$f1->Button(
		-text => 'http://gensen.dl.itc.u-tokyo.ac.jp/',
		-font => "TKFN",
		-foreground => 'blue',
		-activeforeground => 'red',
		-borderwidth => '0',
		-relief => 'flat',
		-cursor => 'hand2',
		-command => sub{
			$self->{win_obj}->after(
				10,
				sub {
					gui_OtherWin->open('http://gensen.dl.itc.u-tokyo.ac.jp/');
				}
			);
		}
	)->pack(-side => 'right');
	
	return $self;
}


sub win_name{
	return 'w_word_search';
}

1;
