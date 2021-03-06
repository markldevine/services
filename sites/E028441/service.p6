use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Application;

$*OUT.out-buffer = 0;

%*ENV<E028441_HOST> = <CTUNIXVMADMINPv.wmata.local>;
%*ENV<E028441_PORT> = 22151;

my $app = Application.new;

my Cro::Service $http = Cro::HTTP::Server.new(
    http => <1.1>,
    host => %*ENV<E028441_HOST> || die("Missing E028441_HOST in environment"),
    port => %*ENV<E028441_PORT> || die("Missing E028441_PORT in environment"),
    application => $app.routes,
    after => [ Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR) ]
);
$http.start;
say "Listening at http://%*ENV<E028441_HOST>:%*ENV<E028441_PORT>";
react {
    whenever signal(SIGHUP) {
        say "Hanging up...";
        $http.stop;
        done;
    }
    whenever signal(SIGINT) {
        say "Shutting down...";
        $http.stop;
        done;
    }
}
