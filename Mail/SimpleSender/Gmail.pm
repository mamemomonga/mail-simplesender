package Mail::SimpleSender::Gmail;
use utf8;
use feature 'say';

# 1. https://console.developers.google.com/ で プロジェクトを作成
# 2. Gmail APIを有効にする
# 3. OAuth 2.0 クライアントIDを作成する。アプリケーションの種類はその他
# 4. 下矢印を押してJSON形式のキーを保存する。

use Google::API::Client;
use Google::API::OAuth2::Client;
use JSON::XS;
use IO::All;
use MIME::Base64;

sub new {
	my($class,%attr)=(shift,@_);
	my $self=bless({},$class);
	while(my($key,$val)=each %attr) {
		$key=lc $key; $self->$key($val);
	}
	return $self;
}

sub client_secret_file { my $self=shift; $self->{client_secret_file}=shift; }
sub access_token_file  { my $self=shift; $self->{access_token_file}=shift;  }
sub user_id            { my $self=shift; $self->{user_id}=shift;  }

sub auth {
	my $self=shift;

	my $auth;
	my $buf=io( $self->{client_secret_file} )->utf8->slurp;
	my $hash=decode_json($buf);
	my %oauth2=();
	foreach(qw( auth_uri token_uri client_id token_uri client_secret)) {
		$oauth2{$_}=$hash->{installed}->{$_};
	};
	$oauth2{redirect_uri}=$hash->{installed}->{redirect_uris}->[0];
	$oauth2{auth_doc}={
		oauth2 => {
			scopes => {
				"https://mail.google.com/"                      => "mail.google.com",
				"https://www.googleapis.com/auth/gmail.compose" => "gmail.compose",
				"https://www.googleapis.com/auth/gmail.modify"  => "gmail.modify",
				"https://www.googleapis.com/auth/gmail.insert"  => "gmail.insert"
			}
		}
	};

	$auth = Google::API::OAuth2::Client->new(\%oauth2);

	if( -e $self->{access_token_file} ) {
		my $token=io($self->{access_token_file})->utf8->slurp;
		$auth->token_obj(decode_json($token));
	} else {

		say "以下のURLにアクセスし、コードをペーストしてください。";
		say $auth->authorize_uri;

		my $code = <STDIN>;
		$auth->exchange($code);
		io($self->{access_token_file})->utf8->print(encode_json($auth->token_obj));
		say "Write: $self->{access_token_file}";
	}

	$self->{oauth_client}=$auth;
}

sub send_draft {
	my ($self,$mail)=@_;

	my $raw=MIME::Base64::encode_base64url($mail->build->as_string);

	my $client = Google::API::Client->new();
	my $service = $client->build('gmail', 'v1');

	my $res = $service->users->drafts->create( body => {

		userId  => $self->{user_id},
		message => { raw => $raw }

	})->execute({"auth_driver"=> $self->{oauth_client}});

	say Dumper($res);
}

sub Dumper {
	eval {
		no warnings;
		require 'Data/Dumper.pm';
		*Data::Dumper::qquote=sub{return shift};
		local $Data::Dumper::Useperl=1;
		my $d=Data::Dumper->new(\@_)->Dump;
		return $d;
	};
}

1;

