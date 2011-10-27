package kh_morpho::win32::stemming;
use strict;
use base qw( kh_morpho::win32 );

use Lingua::Sentence;
use Lingua::Stem::Snowball;
use Lingua::EN::Tagger;


#-----------------------#
#   Stemmer�μ¹Դط�   #
#-----------------------#

sub _run_morpho{
	my $self = shift;	

	if (-e $self->output){
		unlink $self->output or 
			gui_errormsg->open(
				thefile => $self->output,
				type => 'file'
			);
	}

	open (TRGT,$self->target) or 
		gui_errormsg->open(
			thefile => $self->target,
			type => 'file'
		);
	
	open (my $fh_out,'>',$self->output) or 
		gui_errormsg->open(
			thefile => $self->output,
			type => 'file'
		);

	# Perlapp�Ѥ�Lingua::Sentence�Υǡ��������
	if(defined(&PerlApp::extract_bound_file)){
		PerlApp::extract_bound_file(
			'auto/share/dist/Lingua-Sentence/nonbreaking_prefix.ca',
		);
		PerlApp::extract_bound_file(
			'auto/share/dist/Lingua-Sentence/nonbreaking_prefix.de',
		);
		PerlApp::extract_bound_file(
			'auto/share/dist/Lingua-Sentence/nonbreaking_prefix.el',
		);
		PerlApp::extract_bound_file(
			'auto/share/dist/Lingua-Sentence/nonbreaking_prefix.en',
		);
		PerlApp::extract_bound_file(
			'auto/share/dist/Lingua-Sentence/nonbreaking_prefix.es',
		);
		PerlApp::extract_bound_file(
			'auto/share/dist/Lingua-Sentence/nonbreaking_prefix.fr',
		);
		PerlApp::extract_bound_file(
			'auto/share/dist/Lingua-Sentence/nonbreaking_prefix.it',
		);
		PerlApp::extract_bound_file(
			'auto/share/dist/Lingua-Sentence/nonbreaking_prefix.nl',
		);
		PerlApp::extract_bound_file(
			'auto/share/dist/Lingua-Sentence/nonbreaking_prefix.pt',
		);
	}

	# �����̤����꤬ɬ��
	$self->{splitter} = Lingua::Sentence->new('en');
	$self->{stemmer} = Lingua::Stem::Snowball->new( lang => 'en' );
	#$self->{stemmer} = Lingua::Stem->new(-locale => 'EN');
	#$self->{stemmer}->stem_caching({ -level => 2 });

	# Perlapp�Ѥ�Lingua::En::Tagger�Υǡ��������
	unless (-e $Lingua::EN::Tagger::word_path){
		my $cwd = $::config_obj->cwd;
		$cwd = Jcode->new($cwd,'sjis')->euc;
		$cwd =~ tr/\\/\//;
		$cwd = Jcode->new($cwd,'euc')->sjis.'/';
		
		$Lingua::EN::Tagger::word_path
			= $cwd
			.PerlApp::extract_bound_file('Lingua/EN/Tagger/pos_words.hash');
		$Lingua::EN::Tagger::word_path =~ tr/config\\/config\//;
		$Lingua::EN::Tagger::tag_path
			= $cwd
			.PerlApp::extract_bound_file('Lingua/EN/Tagger/pos_tags.hash');
		$Lingua::EN::Tagger::tag_path =~ tr/config\\/config\//;
		$Lingua::EN::Tagger::lexpath
			= substr(
				$Lingua::EN::Tagger::word_path,
				0,
				length($Lingua::EN::Tagger::word_path) - 15
			);
		$Lingua::EN::Tagger::lexpath =~ tr/config\\/config\//;
		
		PerlApp::extract_bound_file('Lingua/EN/Tagger/tags.yml');
		PerlApp::extract_bound_file('Lingua/EN/Tagger/unknown.yml');
		PerlApp::extract_bound_file('Lingua/EN/Tagger/words.yml');
	}

	$self->{tagger} = new Lingua::EN::Tagger;

	# ��������
	while ( <TRGT> ){
		chomp;
		my $t   = $_;
		#$t =~ tr/(?:\x81\x40)/ /; # SJIS�����ѥ��ڡ�����Ⱦ�Ѥ��Ѵ���Win32��
		
		# ���Ф���
		if ($t =~ /^(<h[1-5]>)(.+)(<\/h[1-5]>)$/io){
			print $fh_out "$1\t$1\t$1\t����\n";
			$self->_tokenize_stem($2, $fh_out);
			print $fh_out "$3\t$3\t$3\t����\n";
		} else {
			while ( index($t,'<') > -1){
				my $pre = substr($t,0,index($t,'<'));
				my $cnt = substr(
					$t,
					index($t,'<'),
					index($t,'>') - index($t,'<') + 1
				);
				unless ( index($t,'>') > -1 ){
					gui_errormsg->open(
						msg => '�����å���<>�ˤˤ���������ʤ��ޡ����󥰤�����ޤ�����',
						type => 'msg'
					);
					exit;
				}
				substr($t,0,index($t,'>') + 1) = '';
				
				$self->_sentence($pre, $fh_out);
				$self->_tag($cnt, $fh_out);
				
				#print "[[$pre << $cnt >> $t]]\n";
			}
			$self->_sentence($t, $fh_out);
		}
		print $fh_out "EOS\n";
	}
	close (TRGT);
	close ($fh_out);

	# ���ϥե������SJIS���Ѵ���Win32��
	kh_jchar->to_sjis($self->output);


	return 1;
}

sub _tag{
	my $self = shift;
	my $t    = shift;
	my $fh   = shift;

	$t =~ tr/ /_/;
	print $fh "$t\t$t\t$t\t����\n";

}

sub _sentence{
	my $self = shift;
	my $t    = shift;
	my $fh   = shift;
	
	unless (length($t)){
		#print "Empty!\n";
		return 1;
	}
	
	my @sentences = $self->{splitter}->split_array($t);
	
	foreach my $i (@sentences) {
		$self->_tokenize_stem($i, $fh);
		print $fh "��\t��\t��\tALL\tSP\n";
	}

	return 1;
}


sub _tokenize_stem{
	my $self = shift;
	my $t    = shift;
	my $fh   = shift;
	
	## Tokenize
	##my $tb = $t;
	#use ptb_tokenizer_en;
	#$t = ptb_tokenizer_en::Run($t);
	##my @words = split / /, $t;
	
	# POS Tagging
	$t =~ s/[Cc]annot/can not/go;
	my $t = $self->{tagger}->add_tags($t);
	
	my @words_raw = split / /, $t;
	my @words_hyoso;
	my @words_pos;
	foreach my $i (@words_raw){
		if ($i =~ /^<(.+)>(.+)<\/\1>$/o){
			push @words_pos,   $1;
			push @words_hyoso, $2;
		} else {
			warn("error in tagger? $i\n");
		}
	}
	
	# Stemming
	my @words_stem = $self->{stemmer}->stem(\@words_hyoso) ;
	#my @words_stem = @{ $self->{stemmer}->stem(@words_hyoso) };
	
	# Stemming��̤Υ����å�
	my $n1 = @words_hyoso;
	my $n2 = @words_stem;
	unless ($n1 == $n2){
		print "t: $t\n";
		gui_errormsg->open(
			msg  => "Something wrong: porter stemmer's output",
			type => 'msg',
		);
		exit;
	}
	
	# Stemming��̤�����˵��椬�Ĥ��Ƥ��������Ȥ�
	foreach my $i (@words_stem){
		if ($i =~ /^(\w+)\W+$/o){
			$i = $1;
		}
		elsif ($i =~ /^\W+(\w+)$/o){
			$i = $1;
		}
		#elsif ($i =~ /\w\W/o || $i =~ /\W\w/o){
		#	print "$i,";
		#}
	}
	
	
	# Print
	my $n = 0;
	foreach my $i (@words_hyoso){
		unless (length($words_stem[$n])){
			$words_stem[$n] = $i;
		}
		print $fh "$i\t$i\t$words_stem[$n]\tALL\t\t$words_pos[$n]\n";
		++$n;
	}
	
	return 1;
}

sub exec_error_mes{
	return "KH Coder Error!!\nStemmer�ˤ������˼��Ԥ��ޤ�����";
}


1;
