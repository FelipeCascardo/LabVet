program LabVet;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Horse,
  LabVet.Providers.Config in 'src\providers\LabVet.Providers.Config.pas',
  LabVet.Providers.Connection in 'src\providers\LabVet.Providers.Connection.pas',
  LabVet.Repositories.Base in 'src\repositories\LabVet.Repositories.Base.pas',
  LabVet.Repositories.User in 'src\repositories\LabVet.Repositories.User.pas',
  LabVet.Repositories.Session in 'src\repositories\LabVet.Repositories.Session.pas',
  LabVet.Repositories.Audit in 'src\repositories\LabVet.Repositories.Audit.pas',
  LabVet.Models.Base in 'src\models\LabVet.Models.Base.pas',
  LabVet.Models.ExameCategoria in 'src\models\LabVet.Models.ExameCategoria.pas',
  LabVet.Models.Exame in 'src\models\LabVet.Models.Exame.pas',
  LabVet.Models.TipoAnimal in 'src\models\LabVet.Models.TipoAnimal.pas',
  LabVet.Models.Analito in 'src\models\LabVet.Models.Analito.pas',
  LabVet.Models.ExameAnalito in 'src\models\LabVet.Models.ExameAnalito.pas',
  LabVet.Models.ModeloLaudo in 'src\models\LabVet.Models.ModeloLaudo.pas',
  LabVet.Models.ModeloExameAnalito in 'src\models\LabVet.Models.ModeloExameAnalito.pas',
  LabVet.Models.ModeloExame in 'src\models\LabVet.Models.ModeloExame.pas',
  LabVet.Models.User in 'src\models\LabVet.Models.User.pas',
  LabVet.Models.Auth in 'src\models\LabVet.Models.Auth.pas',
  LabVet.Services.Password in 'src\services\LabVet.Services.Password.pas',
  LabVet.Services.Audit in 'src\services\LabVet.Services.Audit.pas',
  LabVet.Services.User in 'src\services\LabVet.Services.User.pas',
  LabVet.Services.Auth in 'src\services\LabVet.Services.Auth.pas',
  LabVet.Middlewares.Auth in 'src\middlewares\LabVet.Middlewares.Auth.pas',
  LabVet.Controllers.Auth in 'src\controllers\LabVet.Controllers.Auth.pas',
  LabVet.Controllers.User in 'src\controllers\LabVet.Controllers.User.pas';

procedure Health(ARequest: THorseRequest; AResponse: THorseResponse);
begin
  AResponse.ContentType('application/json; charset=utf-8').Send('{"status":"ok"}');
end;

begin
  try
    THorse.Get('/api/v1/health', Health);
    LabVet.Middlewares.Auth.Register;
    LabVet.Controllers.Auth.Register;
    LabVet.Controllers.User.Register;
    Writeln(
      'LabVet API: http://localhost:' +
      TLabVetConfig.GetValue('LABVET_API_PORT', '9010') +
      '/api/v1/health'
    );
    THorse.Listen(StrToInt(TLabVetConfig.GetValue('LABVET_API_PORT', '9010')));
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;
end.
