package gui_window::bayes_view_log;
use base qw(gui_window);

use strict;
use Jcode;
use List::Util qw(max sum);

# ��ʸ��ɽ����Window�Ȥ�Ϣư
# ��и�θ���
# �ۥ�����ǥ������뤹������������������뤷�Ƥ��ޤ�����

#-------------#
#   GUI����   #

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $self->{win_obj};
	$win->title($self->gui_jt('ʬ���'));

	$self->{path} = shift;

	#------------------#
	#   ����Ū�ʾ���   #

	my $lf = $win->LabFrame(
		-label => 'Info',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'x');


	$lf->Label(
		-text => gui_window->gui_jchar('�ؽ���̡�'),
	)->pack(-side => 'left');

	$self->{entry_file_model} = $lf->Entry(
		-width => 12,
	)->pack(-side => 'left',-fill => 'x', -expand => 1);


	$lf->Label(
		-text => gui_window->gui_jchar(' ��¸���ѿ���'),
	)->pack(-side => 'left');

	$self->{entry_outvar} = $lf->Entry(
		-width => 12,
	)->pack(-side => 'left',-fill => 'x', -expand => 1);


	$lf->Label(
		-text => gui_window->gui_jchar(' ʬ��ñ�̡�'),
	)->pack(-side => 'left');

	$self->{entry_tani} = $lf->Entry(
		-width => 6,
	)->pack(-side => 'left');

	$lf->Label(
		-text => gui_window->gui_jchar(' ʸ��No.'),
	)->pack(-side => 'left');

	$self->{entry_dno} = $lf->Entry(
		-width => 6,
	)->pack(-side => 'left');

	$lf->Button(
		-text => gui_window->gui_jchar('ɽ��'),
		-command => sub{ $mw->after(10,sub { $self->select_doc; });} 
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_dno}->bind("<Key-Return>",sub{$self->select_doc;});


	gui_window->disabled_entry_configure( $self->{entry_file_model} );
	gui_window->disabled_entry_configure( $self->{entry_outvar}     );
	gui_window->disabled_entry_configure( $self->{entry_tani}       );

	#--------------------#
	#   ����ʸ��ξ���   #

	$self->{frame_scores} = $win->LabFrame(
		-label => 'Scores',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'x');


	my $lf1 = $win->LabFrame(
		-label => 'Words',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both', -expand => 1);

	$self->{list_flame} = $lf1->Frame()->pack(-fill => 'both', -expand => 1);

	#------------------#
	#   ���ܥ�����   #

	my $f1 = $lf1->Frame()->pack(-fill => 'x');

	$f1->Label(
		-text => gui_window->gui_jchar('��и측����'),
	)->pack(-side => 'left');

	$self->{entry_wsearch} = $f1->Entry(
		-width => 15,
	)->pack(-side => 'left', -fill => 'x', -expand => 1);

	$f1->Button(
		-text => gui_window->gui_jchar('����'),
	)->pack(-side => 'left', -padx => 2);

	$f1->Label(
		-text => '  ',
	)->pack(-side => 'left');

	my $btn = $f1->Button(
		-text => gui_window->gui_jchar('���ԡ���ɽ���Ρ�'),
		-command => sub{ $mw->after(10,sub { $self->copy; });} 
	)->pack(-side => 'left', -padx => 2);
	
	$self->win_obj->bind(
		'<Control-Key-c>',
		sub{ $btn->invoke; }
	);
	$self->win_obj->Balloon()->attach(
		$btn,
		-balloonmsg => 'Ctrl + C',
		-font => "TKFN"
	);
	
	return $self;
}

#------------#
#   �����   #

sub start{
	my $self = shift;
	$self->{log_obj} = Storable::retrieve($self->{path});
	
	# ��ǥ�ե�����̾
	use File::Basename;
	my $fm = gui_window->gui_jchar($self->{log_obj}{file_model});
	$fm = File::Basename::basename($fm);

	$self->{entry_file_model}->configure(-state => 'normal');
	$self->{entry_file_model}->delete(0,'end');
	$self->{entry_file_model}->insert(0,$fm);
	$self->{entry_file_model}->configure(-state => 'disable');

	# �ѿ�̾
	$self->{entry_outvar}->configure(-state => 'normal');
	$self->{entry_outvar}->delete(0,'end');
	$self->{entry_outvar}->insert(0,
		gui_window->gui_jchar($self->{log_obj}{outvar},'euc')
	);
	$self->{entry_outvar}->configure(-state => 'disable');

	# ñ��
	my $tani = $self->{log_obj}{tani};
	$tani = 'ʸ'   if $tani eq 'bun';
	$tani = '����' if $tani eq 'dan';

	$self->{entry_tani}->configure(-state => 'normal');
	$self->{entry_tani}->delete(0,'end');
	$self->{entry_tani}->insert(0,
		gui_window->gui_jchar($tani,'euc')
	);
	$self->{entry_tani}->configure(-state => 'disable');

	# ���ե�����̾
	my $fl = gui_window->gui_jchar($self->{path});
	$fl = File::Basename::basename($fl);
	$fl = Jcode->new( gui_window->gui_jg($fl) )->euc;
	$self->{win_obj}->title($self->gui_jt("ʬ����� $fl"));

	# ɽ������ʸ�������
	$self->{current} = 1;
	$self->view;
	
	return $self;
}

#----------------------#
#   ʸ��ξ����ɽ��   #

sub select_doc{
	my $self = shift;
	my $doc = $self->gui_jg( $self->{entry_dno}->get );
	$self->{current} = $doc;
	$self->view;
	return $self;
}


sub view{
	my $self = shift;

	#------------------------------#
	#   ɽ������ʸ���Ѥ����   #

	my $selected_by_bayes;
	unless ( $self->{current} == $self->{ready} ){
		# �ơ��֥�ν���
		my $scores;
		($self->{result}, $scores) =
			&kh_nbayes::predict::make_each_log_table(
				$self->{log_obj}{log}{$self->{current}},
				$self->{log_obj}{labels},
				$self->{log_obj}{fixer}
			)
		;
		
		# ʸ���ֹ��ɽ��
		$self->{entry_dno}->delete(0,'end');
		$self->{entry_dno}->insert(0, $self->{current});
		
		# ��������ɽ��
		$self->{frame_scores_a}->destroy if $self->{frame_scores_a};
		$self->{frame_scores_a} = $self->{frame_scores}->Frame()->pack(
			-fill => 'x'
		);
		my $n = 0;
		foreach my $i (
			sort { $scores->{$b} <=> $scores->{$a} }
			keys %{$scores}
		){
			
			unless ($n + 1){
				$self->{frame_scores_a}->Label(
					-text => $self->gui_jchar('ʬ�ࡧ'),
				)->pack(-side => 'left');
				
				my @len;
				foreach my $h (@{$self->{log_obj}{labels}}){
					push @len, length( $h );
				}
				my $width = max(@len);
				
				my $e = $self->{frame_scores_a}->Entry(
					-width => $width + 2,
				)->pack(-side => 'left', -fill => 'x', -expand => 1);
				
				$e->insert(0, $self->gui_jchar($i) );
				$e->configure(-state => 'disable');
				gui_window->disabled_entry_configure( $e );
			}
			
			$selected_by_bayes = $i unless $n;
			$self->{frame_scores_a}->Label(
				-text => ' '
			)->pack(-side => 'left') if $n;

			$self->{frame_scores_a}->Label(
				-text => $self->gui_jchar($i.'��'),
			)->pack(-side => 'left');
			
			my $ent = $self->{frame_scores_a}->Entry(
				-width => 8,
			)->pack(
				-side => 'left',
				#-fill => 'x',
				#-expand => 1
			);
			
			$ent->insert(0, sprintf("%.2f",$scores->{$i}) );
			$ent->configure(-state => 'disable');
			gui_window->disabled_entry_configure( $ent );
			
			++$n;
			#last if $n >= 5;
		}
		$self->{frame_scores_a}->Label(
			-text => $self->gui_jchar(' �������饹�����ι⤤���ɽ��'),
		)->pack(-side => 'left');
		
		$self->{last_sort_key} = undef;
		$self->{ready} = $self->{current};
	}

	#--------------------#
	#   ��и�Υꥹ��   #

	my $width = 0;
	foreach my $i (keys %{$self->{log_obj}{log}{$self->{current}}} ){
		if ( length($i) > $width ){
			$width = length($i);
		}
	}
	my $cols = 2 + 1 + @{$self->{log_obj}{labels}} * 2;

	$self->{list}->destroy if $self->{list};                # �Ť���Τ��Ѵ�
	$self->{list2}->destroy if $self->{list2};
	$self->{sb1}->destroy if $self->{sb1};
	$self->{sb2}->destroy if $self->{sb2};
	$self->{list_flame_inner}->destroy if $self->{list_flame_inner};

	$self->{list_flame_inner} = $self->{list_flame}->Frame( # �����ʥꥹ�Ⱥ���
		-relief      => 'sunken',
		-borderwidth => 2
	);
	$self->{list2} = $self->{list_flame_inner}->HList(
		-header             => 1,
		-itemtype           => 'text',
		-font               => 'TKFN',
		-columns            => 1,
		-padx               => 2,
		-background         => 'white',
		-selectbackground   => 'white',
		-selectforeground   => 'black',
		-selectmode         => 'extended',
		-height             => 10,
		-width              => $width,
		-borderwidth        => 0,
		-highlightthickness => 0,
	);
	$self->{list2}->header('create',0,-text => ' ');
	$self->{list} = $self->{list_flame_inner}->HList(
		-header             => 1,
		-itemtype           => 'text',
		-font               => 'TKFN',
		-columns            => $cols - 1,
		-padx               => 2,
		-background         => 'white',
		-selectforeground   => 'black',
		-selectmode         => 'extended',
		-height             => 10,
		-borderwidth        => 0,
		-highlightthickness => 0,
	);

	my $col = 0;                                            # Header����
	my @temp = ();
	foreach my $i ( @{$self->{log_obj}{labels}} ){
		push @temp, $i.' (%)';
	}
	foreach my $i (
		'��и�', '����', @{$self->{log_obj}{labels}}, '  ', @temp
	){
		unless ($col){
			++$col;
			next;
		}
		my $w = $self->{list}->Label(
			-text               => $self->gui_jchar($i),
			-font               => "TKFN",
			-foreground         => 'blue',
			-cursor             => 'hand2',
			-padx               => 0,
			-pady               => 0,
			-borderwidth        => 0,
			-highlightthickness => 0,
		);
		my $key = $col;
		unless ( $i eq '  ' ){
			$w->bind(
				"<Button-1>",
				sub{
					$w->after(10, sub { $self->sort($key); } );
				}
			);
			$w->bind(
				"<Enter>",
				sub{
					$w->after(10, sub { $w->configure(-foreground => 'red'); } );
				}
			);
			$w->bind(
				"<Leave>",
				sub{
					$w->after(10, sub { $w->configure(-foreground => 'blue'); } );
				}
			);
		}
		$self->{list}->header(
			'create',
			$col - 1,
			-itemtype  => 'window',
			-widget    => $w,
		);
		++$col;
	}

	my $sb1 = $self->{list_flame}->Scrollbar(               # ������������
		-orient  => 'v',
		-command => [ \&multiscrolly, $self->{sb1}, [$self->{list}, $self->{list2}]]
	);
	my $sb2 = $self->{list_flame}->Scrollbar(
		-orient => 'h',
		-command => ['xview' => $self->{list}]
	);
	$self->{list}->configure( -yscrollcommand => ['set', $sb1] );
	$self->{list}->configure( -xscrollcommand => ['set', $sb2] );
	$self->{list2}->configure( -yscrollcommand => ['set', $sb1] );
	$self->{sb1} = $sb1;
	$self->{sb2} = $sb2;
	
	$sb1->pack(-side => 'right', -fill => 'y');             # Pack
	$self->{list_flame_inner}->pack(-fill =>'both',-expand => 'yes');
	$self->{list2}->pack(-side => 'left', -fill =>'y', -pady => 0);
	$self->{list}->pack(-fill =>'both',-expand => 'yes', -pady => 0);
	$sb2->pack(-fill => 'x');

	#--------------------#
	#   ��и�Υꥹ��   #
	
	my $n = 2;
	my $key;
	foreach my $i (@{$self->{log_obj}{labels}}){
		$key = $n if $selected_by_bayes eq $i;
		++$n;
	}
	
	$self->sort($key);

	
	return $self;
}

#--------------------------#
#   ��и�Υ����ȡ�ɽ��   #

sub sort{
	my $self = shift;
	my $key  = shift;
	$key = 0 if $self->{last_sort_key} == $key;
	
	$self->{list}->delete('all');
	$self->{list2}->delete('all');
	
	# ������
	my @temp;
	if ($key){
		@temp = sort { $b->[$key] <=> $a->[$key] } @{$self->{result}};
		#$self->{btn_copy}->configure(
		#	-text => $self->gui_jchar('���ԡ����������')
		#);
	} else {
		@temp = @{$self->{result}};
		#$self->{btn_copy}->configure(
		#	-text => $self->gui_jchar('���ԡ���ɽ���Ρ�')
		#);
	}

	# ����
	my $right_style = $self->{list}->ItemStyle(
		'text',
		-font => "TKFN",
		-anchor => 'e',
	);
	my $row = 0;
	foreach my $i ( @temp ){
		$self->{list}->add($row,-at => "$row");
		$self->{list2}->add($row,-at => "$row");
		my $col = 0;
		foreach my $h (@{$i}){
			if ($col){
				$self->{list}->itemCreate(
					$row,
					$col - 1,
					-text  => $h,
					-style => $right_style
				);
			} else {
				$self->{list2}->itemCreate(
					$row,
					0,
					-text  => $self->gui_jchar($h,'euc')
				);
			}
			++$col;
		}
		++$row;
	}
	$self->{list}->yview(0);
	$self->{list2}->yview(0);
	
	# ��٥�ο����ѹ�
	if ($key){
		my $w = $self->{list}->header(
			'cget',
			$key - 1,
			'-widget'
		);
		$w->configure(
			-foreground => 'red',
			#-cursor => undef
		);
		$w->bind(
			"<Leave>",
			sub{
				$w->after(
					10,
					sub { $w->configure(-foreground => 'red'); }
				);
			}
		);
	}
	
	# �����ѹ�������٥�ο��򸵤��᤹
	if ($self->{last_sort_key}){
		my $lw = $self->{list}->header(
			'cget',
			$self->{last_sort_key} - 1,
			'-widget'
		);
		$lw->configure(
			-foreground => 'blue',
			#-cursor => 'hand2'
		);
		$lw->bind(
			"<Leave>",
			sub{
				$lw->after(
					10,
					sub { $lw->configure(-foreground => 'blue'); }
				);
			}
		);
	}
	
	$self->{last_sort_key} = $key;
	return $self;
}

sub multiscrolly{
	my ($sb,$wigs,@args) = @_;
	my $w;
	foreach $w (@$wigs){
		$w->yview(@args);
	}
}

sub copy{
	my $self = shift;
	
	return 0 unless $self->{result};
	
	# 1����
	my $clip = "\t";
	
	my $cols = @{$self->{result}->[0]} - 2;
	for (my $n = 0; $n <= $cols; ++$n){
		#if ($self->{last_sort_key}){
		#	unless ($n + 1 == $self->{last_sort_key}){
		#		next;
		#	}
		#}
		
		my $w = $self->{list}->header(
			'cget',
			$n,
			'-widget'
		);
		$clip .= $w->cget('-text')."\t";
	}
	chop $clip;
	$clip .= "\n";
	
	# ���
	my $rows = @{$self->{result}} - 2;
	for (my $r = 0; $r <= $rows; ++$r){
		# 1����
		if ($self->{list2}->itemExists($r, 0)){
			my $cell = $self->{list2}->itemCget($r, 0, -text);
			chop $cell if $cell =~ /\r$/o;
			$clip .= "$cell\t";
		} else {
			$clip .= "\t";
		}
		# 2���ܰʹ�
		for (my $c = 0; $c <= $cols; ++$c){
			#if ($self->{last_sort_key}){
			#	unless ($c + 1 == $self->{last_sort_key}){
			#		next;
			#	}
			#}
		
			if ($self->{list}->itemExists($r, $c)){
				my $cell = $self->{list}->itemCget($r, $c, -text);
				chop $cell if $cell =~ /\r$/o;
				$clip .= "$cell\t";
			} else {
				$clip .= "\t";
			}
		}
		chop $clip;
		$clip .= "\n";
	}
	
	$clip = gui_window->gui_jg($clip);
	require Win32::Clipboard;
	my $CLIP = Win32::Clipboard();
	$CLIP->Set("$clip");
}


sub win_name{
	return 'w_bayes_view_log';
}

1;