package gui_window::word_conc_coloc;
use base qw(gui_window);
use vars qw($filter);

use strict;
use Statistics::Lite qw(max);
use gui_hlist;

#------------------#
#   Window�����   #
#------------------#

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $wmw= $mw->Toplevel;
	$self->{win_obj} = $wmw;
	$wmw->title($self->gui_jchar('���������������'));
	
	# Nord Word�ξ���ɽ����ʬ
	
	my $fra4 = $wmw->LabFrame(
		-label => 'Nord Word',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill=>'x');
	
	$fra4->Label(
		-text => $self->gui_jchar('����и졧'),
		-font => "TKFN"
	)->pack(-side => 'left');
	
	my $e1 = $fra4->Entry(
		-font => "TKFN",
		-background => 'gray',
		-width => 14,
		-state => 'disable',
	)->pack(-side => 'left');
	
	$fra4->Label(
		-text => $self->gui_jchar('���ʻ졧'),
		-font => "TKFN"
	)->pack(-side => 'left');
	
	my $e4 = $fra4->Entry(
		-font => "TKFN",
		-background => 'gray',
		-width => 8,
		-state => 'disable',
	)->pack(-side => 'left');

	$fra4->Label(
		-text => $self->gui_jchar('�����ѷ���'),
		-font => "TKFN"
	)->pack(-side => 'left');

	my $e2 = $fra4->Entry(
		-font => "TKFN",
		-width => 8,
		-background => 'gray',
		-state => 'disable',
	)->pack(-side => 'left');

	$self->{label} = $fra4->Label(
		-text => $self->gui_jchar('  �ҥåȿ���'),
		-font => "TKFN"
	)->pack(-side => 'left');


	# ���׷�̤�ɽ��������ʬ

	my $fra5 = $wmw->LabFrame(
		-label => 'Result',
		-labelside => 'acrosstop',
		-borderwidth => 2
	)->pack(-expand=>'yes',-fill=>'both');

	my $hlist_fra = $fra5->Frame()->pack(-expand => 'y', -fill => 'both');

	my $lis = $hlist_fra->Scrolled(
		'HList',
		-scrollbars       => 'osoe',
		-header           => 1,
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => 16,
		-padx             => 2,
		-background       => 'white',
		#-selectforeground => 'black',
		#-selectbackground => 'cyan',
		-selectmode       => 'extended',
		-height           => 20,
		#-command          => sub {$mw->after(10,sub{$self->view_doc;});}
	)->pack(-fill =>'both',-expand => 'yes');

	my $style_blue = $lis->ItemStyle(
		'text',
		-font => "TKFN",
		-foreground => 'blue',
		#-background => 'white'
	);
	my $style_green = $lis->ItemStyle(
		'text',
		-font => "TKFN",
		-foreground => '#008000',
		#-background => 'white'
	);

	$lis->header('create',0,-text  => 'N');
	$lis->header('create',1,-text  => $self->gui_jchar('��и�'));
	$lis->header('create',2,-text  => $self->gui_jchar('�ʻ�'));
	$lis->header('create',3,-text  => $self->gui_jchar('���'));
	$lis->header('create',4,-text  => $self->gui_jchar('�����'));
	$lis->header('create',5,-text  => $self->gui_jchar('�����'));
	$lis->header(
		'create', 6,
		-text  => $self->gui_jchar('��5'),
		-style => $style_blue
	);
	$lis->header(
		'create',7,
		-text  => $self->gui_jchar('��4'),
		-style => $style_blue
	);
	$lis->header(
		'create',8,
		-text  => $self->gui_jchar('��3'),
		-style => $style_blue
	);
	$lis->header(
		'create',9,
		-text  => $self->gui_jchar('��2'),
		-style => $style_blue
	);
	$lis->header(
		'create',10,
		-text  => $self->gui_jchar('��1'),
		-style => $style_blue
	);
	#$lis->header('create',11,-text => $self->gui_jchar('*'));
	$lis->header(
		'create',11,
		-text => $self->gui_jchar('��1'),
		-style => $style_green
	);
	$lis->header(
		'create',12,
		-text => $self->gui_jchar('��2'),
		-style => $style_green
	);
	$lis->header(
		'create',13,
		-text => $self->gui_jchar('��3'),
		-style => $style_green
	);
	$lis->header(
		'create',14,
		-text => $self->gui_jchar('��4'),
		-style => $style_green
	);
	$lis->header(
		'create',15,
		-text => $self->gui_jchar('��5'),
		-style => $style_green
	);

	# �������ѤΥܥ�����

	$fra5->Button(
		-text => $self->gui_jchar('���ԡ�'),
		-font => "TKFN",
		-width => 8,
		-borderwidth => '1',
		-command => sub{ $mw->after(10,sub {gui_hlist->copy($self->list);});} 
	)->pack(-side => 'left',-anchor => 'w', -pady => 1, -padx => 2);

	$fra5->Label(
		-text => $self->gui_jchar('�������ȡ�'),
		-font => "TKFN"
	)->pack(-side => 'left');

	my @options = (
		[ $self->gui_jchar('���'),   'sum'],
		[ $self->gui_jchar('�����'), 'suml'],
		[ $self->gui_jchar('�����'), 'sumr'],
		[ $self->gui_jchar('����5'),  'l5'],
		[ $self->gui_jchar('����4'),  'l4'],
		[ $self->gui_jchar('����3'),  'l3'],
		[ $self->gui_jchar('����2'),  'l2'],
		[ $self->gui_jchar('����1'),  'l1'],
		[ $self->gui_jchar('����1'),  'r1'],
		[ $self->gui_jchar('����2'),  'r2'],
		[ $self->gui_jchar('����3'),  'r3'],
		[ $self->gui_jchar('����4'),  'r4'],
		[ $self->gui_jchar('����5'),  'r5']
	);

	$self->{menu1} = gui_widget::optmenu->open(
		parent   => $fra5,
		pack     => {-anchor=>'e', -side => 'left'},
		options  => \@options,
		variable => \$self->{sort},
		width    => 6,
		command  => sub{ $mw->after(10,sub{$self->view;});} 
	);

	$fra5->Label(
		-text => $self->gui_jchar('��'),
		-font => "TKFN"
	)->pack(-side => 'left');

	$fra5->Button(
		-text => $self->gui_jchar('�ե��륿����'),
		-font => "TKFN",
		-borderwidth => '1',
		-command => sub{ $mw->after(10,sub {gui_window::word_conc_coloc_opt->open;});}
	)->pack(-side => 'left',-anchor => 'w', -pady => 1, -padx => 2);

	# �ե��륿����ν����
	
	$filter = undef;
	$filter->{limit}   = 200;                  # LIMIT��
	my $h = mysql_exec->select("               # �ʻ�ˤ��ե��륿
		SELECT khhinshi_id
		FROM   hselection
		WHERE  ifuse = 1
	",1)->hundle;
	while (my $i = $h->fetch){
		$filter->{hinshi}{$i->[0]} = 1;
	}

	# ����¾���ǽ�����
	
	$self->disabled_entry_configure($e1);
	$self->disabled_entry_configure($e4);
	$self->disabled_entry_configure($e2);

	$self->{entry}{nw_w} = $e1;
	$self->{entry}{nw_h} = $e4;
	$self->{entry}{nw_k} = $e2;
	$self->{hlist}       = $lis;

	return $self;
}

#--------------#
#   ���ɽ��   #
#--------------#

sub view{
	my $self = shift;
	$self->{result_obj} = shift if defined($_[0]);
	
	# nord word �����ɽ��
	$self->{entry}{nw_w}->configure(-state => 'normal');
	$self->{entry}{nw_h}->configure(-state => 'normal');
	$self->{entry}{nw_k}->configure(-state => 'normal');
	$self->{entry}{nw_w}->delete(0,'end');
	$self->{entry}{nw_h}->delete(0,'end');
	$self->{entry}{nw_k}->delete(0,'end');
	if ($self->{result_obj}){
		$self->{entry}{nw_w}->insert(
			'end',
			$self->gui_jchar($self->{result_obj}{query})
		);
		$self->{entry}{nw_h}->insert(
			'end',
			$self->gui_jchar($self->{result_obj}{hinshi})
		);
		$self->{entry}{nw_k}->insert(
			'end',
			$self->gui_jchar($self->{result_obj}{katuyo})
		);
	}
	$self->{entry}{nw_w}->configure(-state => 'disable');
	$self->{entry}{nw_h}->configure(-state => 'disable');
	$self->{entry}{nw_k}->configure(-state => 'disable');
	my $hit_numb;
	$hit_numb = $self->{result_obj}->_count if $self->{result_obj};
	$self->{label}->configure(
		-text => $self->gui_jchar("  �ҥåȿ��� $hit_numb")
	);
	
	$self->list->delete('all');
	$self->win_obj->update;
	
	# ���׷�̤μ���
	return unless $self->{result_obj};
	my $res = $self->{result_obj}->format_coloc(
		sort   => $self->{sort},
		filter => $filter,
	);
	return unless $res;
	
	# ���׷�̤�ɽ��
	my $right_style = $self->list->ItemStyle(
		'text',
		-font             => "TKFN",
		-anchor           => 'e',
		-background       => 'white'
	);
	my $right_style_blue = $self->list->ItemStyle(
		'text',
		-font             => "TKFN",
		-anchor           => 'e',
		-foreground       => 'blue',
		-selectforeground => 'blue',
		-background       => 'white'
	);
	my $right_style_green = $self->list->ItemStyle(
		'text',
		-font             => "TKFN",
		-anchor           => 'e',
		-foreground       => '#008000',
		-selectforeground => '#008000',
		-background       => 'white'
	);
	my $right_style_red = $self->list->ItemStyle(
		'text',
		-font             => "TKFN",
		-anchor           => 'e',
		-foreground       => 'red',
		-selectforeground => 'red',
		-background       => 'white'
	);
	
	my $row = 0;
	foreach my $i (@{$res}){
		$self->list->add($row,-at => "$row");
		$self->list->itemCreate(
			$row,
			0,
			-text => $row + 1,
			-style => $right_style
		);
		
		my $col = 1;
		my $max = max @{$i}[5...14];
		foreach my $h (@{$i}){
			if ($col > 2){              # ����
				my $style;
				if ($col < 6){
					$style = $right_style;
				}
				elsif ($h == $max) {
					$style = $right_style_red;
				}
				elsif ($col < 11){
					$style = $right_style_blue;
				}
				else {
					$style = $right_style_green;
				}
				$self->list->itemCreate(
					$row,
					$col,
					-text  => $h,
					-style => $style
				);
			} else {                    # ���ܸ�ʸ��
				$self->list->itemCreate(
					$row,
					$col,
					-text  => $self->gui_jchar($h,'euc')
				);
			}
			++$col;
		}
		++$row;
	}
}


#--------------#
#   ��������   #

sub list{
	my $self = shift;
	return $self->{hlist};
}

sub win_name{
	return 'w_word_conc_coloc';
}

1;