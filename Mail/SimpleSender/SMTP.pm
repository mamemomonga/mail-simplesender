package Mail::SimpleSender::SMTP;
use utf8;
use Net::SMTP;

sub new {
	my($class,@attr)=@_;
	my $self={};
	bless($self,$class);
	$self->{smtp}=Net::SMTP->new(@attr);
	return $self;
}

sub send {
	my ($self,$mail)=@_;
	my $smtp=$self->{smtp};
	my $email=$mail->build;
	$smtp->mail($mail->{sender}) || die $smtp->message;
	$smtp->to($mail->{headers}->{To}) || die $smtp->message;
	if($mail->{headers}->{Cc}){  $smtp->cc($mail->{headers}->{Cc}) || die $smtp->message }
	if($mail->{headers}->{Bcc}){ $smtp->bcc($mail->{headers}->{Bcc}) || die $smtp->message }
	$smtp->data($email->as_string) || die $smtp->message;
}

1;

