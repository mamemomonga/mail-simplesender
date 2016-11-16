package Mail::SimpleSender;
use 5.8.8;
use utf8;
use strict;
use warnings;

use Encode;
use Email::MIME;
use File::Basename;

sub new {
	my($class,%attr)=(shift,@_);
	my $self=bless({},$class);
	while(my($key,$val)=each %attr) {
		$key=lc $key; $self->$key($val);
	}
	return $self;
}

sub header {
	my ($self,$hdr,$val)=@_;
	$self->{headers}||={};
	$self->{headers}->{$hdr}=$val if $val;
	return $self->{headers}->{$hdr};
}

sub attach {
	my ($self,$attr)=(shift,{@_});
	$self->{parts}||=[];

	my $name=$attr->{name} ? $attr->{name} : basename($attr->{filename});

	my $body;
	open(my $fh,'<:raw',$attr->{filename}) || die "$! - $attr->{filename}";
	{ local $/; $body=<$fh> }

	push @{$self->{parts}},Email::MIME->create(
		attributes => {
			filename     => $name,
			name         => $name,
			encoding     => 'base64',
			content_type => $attr->{type} ? $attr->{type} : 'application/octet-stream',
		},
		body => $body
	);
}

sub to { shift->header('To',shift) }

sub cc { shift->header('Cc',shift) }

sub bcc { shift->header('Bcc',shift) }

sub reply { shift->header('Reply-To',shift) }

sub return_path { shift->header('Return-Path',shift) }

sub subject {
	my $self=shift;
	my $buf=encode('MIME-Header-ISO_2022_JP'=>shift);
	$buf=~s/\r//g; $buf=~s/\n//g;
	$self->header('Subject',$buf);
}

sub from {
	my $self=shift;
	my $buf=encode('MIME-Header-ISO_2022_JP'=>shift);
	$buf=~s/\r//g; $buf=~s/\n//g;
	$self->header('From',$buf);
}

sub sender {
	my $self=shift;
	$self->{sender}=shift;
}

sub mailer {
	my $self=shift;
	$self->{mailer}=shift;
}

sub text {
	my $self=shift;
	$self->{text}=encode('ISO-2022-JP'=>shift);
}

sub build {
	my $self=shift;
	my $email=Email::MIME->create(
		header => [ %{ $self->{headers} } ],
		attributes => {
			content_type => 'text/plain',
			charset      => 'ISO-2022-JP',
			encoding     => '7bit'
		},
		body => $self->{text}
	);

	if($self->{parts}) {
		push @{$self->{parts}},$email;
		$email=Email::MIME->create(
			header => [ %{ $self->{headers} } ],
			parts  => $self->{parts},
		);
	}
	return $email;
}

1;

