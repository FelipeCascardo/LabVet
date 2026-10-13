program LabVet;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Horse,
  LabVet.Providers.Config in 'src\providers\LabVet.Providers.Config.pas',
  LabVet.Providers.Connection in 'src\providers\LabVet.Providers.Connection.pas',
  LabVet.Repositories.Base in 'src\repositories\LabVet.Repositories.Base.pas',
  LabVet.Repositories.ExameCategoria in 'src\repositories\LabVet.Repositories.ExameCategoria.pas',
  LabVet.Repositories.Exame in 'src\repositories\LabVet.Repositories.Exame.pas',
  LabVet.Repositories.AnimalGrupo in 'src\repositories\LabVet.Repositories.AnimalGrupo.pas',
  LabVet.Repositories.Analito in 'src\repositories\LabVet.Repositories.Analito.pas',
  LabVet.Repositories.ExameAnalito in 'src\repositories\LabVet.Repositories.ExameAnalito.pas',
  LabVet.Repositories.ModeloExameAnalito in 'src\repositories\LabVet.Repositories.ModeloExameAnalito.pas',
  LabVet.Repositories.ModeloExame in 'src\repositories\LabVet.Repositories.ModeloExame.pas',
  LabVet.Repositories.User in 'src\repositories\LabVet.Repositories.User.pas',
  LabVet.Repositories.Session in 'src\repositories\LabVet.Repositories.Session.pas',
  LabVet.Repositories.Audit in 'src\repositories\LabVet.Repositories.Audit.pas',
  LabVet.Models.Base in 'src\models\LabVet.Models.Base.pas',
  LabVet.Models.ExameCategoria in 'src\models\LabVet.Models.ExameCategoria.pas',
  LabVet.Models.Exame in 'src\models\LabVet.Models.Exame.pas',
  LabVet.Models.AnimalGrupo in 'src\models\LabVet.Models.AnimalGrupo.pas',
  LabVet.Models.Analito in 'src\models\LabVet.Models.Analito.pas',
  LabVet.Models.ExameAnalito in 'src\models\LabVet.Models.ExameAnalito.pas',
  LabVet.Models.ModeloExameAnalito in 'src\models\LabVet.Models.ModeloExameAnalito.pas',
  LabVet.Models.ModeloExame in 'src\models\LabVet.Models.ModeloExame.pas',
  LabVet.Models.User in 'src\models\LabVet.Models.User.pas',
  LabVet.Models.Auth in 'src\models\LabVet.Models.Auth.pas',
  LabVet.Services.Password in 'src\services\LabVet.Services.Password.pas',
  LabVet.Services.Audit in 'src\services\LabVet.Services.Audit.pas',
  LabVet.Services.Analito in 'src\services\LabVet.Services.Analito.pas',
  LabVet.Services.AnimalGrupo in 'src\services\LabVet.Services.AnimalGrupo.pas',
  LabVet.Services.ExameCategoria in 'src\services\LabVet.Services.ExameCategoria.pas',
  LabVet.Services.Exame in 'src\services\LabVet.Services.Exame.pas',
  LabVet.Services.ExameAnalito in 'src\services\LabVet.Services.ExameAnalito.pas',
  LabVet.Services.ModeloExame in 'src\services\LabVet.Services.ModeloExame.pas',
  LabVet.Services.ModeloExameAnalito in 'src\services\LabVet.Services.ModeloExameAnalito.pas',
  LabVet.Services.User in 'src\services\LabVet.Services.User.pas',
  LabVet.Services.Auth in 'src\services\LabVet.Services.Auth.pas',
  LabVet.Middlewares.Auth in 'src\middlewares\LabVet.Middlewares.Auth.pas',
  LabVet.Controllers.Auth in 'src\controllers\LabVet.Controllers.Auth.pas',
  LabVet.Controllers.User in 'src\controllers\LabVet.Controllers.User.pas',
  LabVet.Controllers.Base in 'src\controllers\LabVet.Controllers.Base.pas',
  LabVet.Controllers.Analito in 'src\controllers\LabVet.Controllers.Analito.pas',
  LabVet.Controllers.AnimalGrupo in 'src\controllers\LabVet.Controllers.AnimalGrupo.pas',
  LabVet.Controllers.ExameCategoria in 'src\controllers\LabVet.Controllers.ExameCategoria.pas',
  LabVet.Controllers.Exame in 'src\controllers\LabVet.Controllers.Exame.pas',
  LabVet.Controllers.ExameAnalito in 'src\controllers\LabVet.Controllers.ExameAnalito.pas',
  LabVet.Controllers.ModeloExame in 'src\controllers\LabVet.Controllers.ModeloExame.pas',
  LabVet.Controllers.ModeloExameAnalito in 'src\controllers\LabVet.Controllers.ModeloExameAnalito.pas';

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
    LabVet.Controllers.Analito.Register;
    LabVet.Controllers.AnimalGrupo.Register;
    LabVet.Controllers.ExameCategoria.Register;
    LabVet.Controllers.Exame.Register;
    LabVet.Controllers.ExameAnalito.Register;
    LabVet.Controllers.ModeloExame.Register;
    LabVet.Controllers.ModeloExameAnalito.Register;
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
