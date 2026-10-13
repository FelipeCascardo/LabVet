unit LabVet.Services.ModeloExameAnalito;

interface

uses
  System.Generics.Collections,
  System.SysUtils,

  LabVet.Models.ModeloExameAnalito;

type
  EModeloExameAnalitoValidacao = class(Exception);
  EModeloExameAnalitoNaoEncontrado = class(Exception);

  TModeloExameAnalitoService = class
  private
    procedure NormalizarReferencias(AValue: TModeloExameAnalito);
    procedure Validar(AValue: TModeloExameAnalito);
    procedure ValidarReferencias(AValue: TModeloExameAnalito);
  public
    function ListarPorModelo(
      AIdModeloExame: Int64
    ): TObjectList<TModeloExameAnalito>;
    function ObterPorId(AId: Int64): TModeloExameAnalito;
    function Criar(
      AValue: TModeloExameAnalito;
      AActorId: Int64
    ): TModeloExameAnalito;
    function Atualizar(
      AId: Int64;
      AValue: TModeloExameAnalito;
      AActorId: Int64
    ): TModeloExameAnalito;
    procedure DefinirAtivo(
      AId: Int64;
      AAtivo: Boolean;
      AActorId: Int64
    );
  end;

implementation

uses
  LabVet.Models.Analito,
  LabVet.Models.ExameAnalito,
  LabVet.Repositories.Analito,
  LabVet.Repositories.ExameAnalito,
  LabVet.Repositories.ModeloExameAnalito;

procedure TModeloExameAnalitoService.NormalizarReferencias(
  AValue: TModeloExameAnalito
);
begin
  if AValue.VrRefMinimo.PossuiValor then
  begin
    AValue.VrRefMinimo.Valor := AValue.VrRefMinimo.Valor.Trim;
    AValue.VrRefMinimo.PossuiValor := not AValue.VrRefMinimo.Valor.IsEmpty;
  end;

  if AValue.VrRefMaximo.PossuiValor then
  begin
    AValue.VrRefMaximo.Valor := AValue.VrRefMaximo.Valor.Trim;
    AValue.VrRefMaximo.PossuiValor := not AValue.VrRefMaximo.Valor.IsEmpty;
  end;
end;

procedure TModeloExameAnalitoService.Validar(
  AValue: TModeloExameAnalito
);
begin
  if not Assigned(AValue) then
    raise EModeloExameAnalitoValidacao.Create('Item do modelo obrigatório.');

  if AValue.IdModeloExame <= 0 then
    raise EModeloExameAnalitoValidacao.Create('Informe o modelo de exame.');

  if AValue.IdExameAnalito <= 0 then
    raise EModeloExameAnalitoValidacao.Create('Informe o analito do exame.');

  if AValue.NrExibicao <= 0 then
    raise EModeloExameAnalitoValidacao.Create(
      'A ordem de exibição deve ser maior que zero.'
    );

  if AValue.VrRefPerMinimo.PossuiValor and
    ((AValue.VrRefPerMinimo.Valor < 0) or
    (AValue.VrRefPerMinimo.Valor > 100)) then
    raise EModeloExameAnalitoValidacao.Create(
      'A referência percentual mínima deve estar entre 0 e 100.'
    );

  if AValue.VrRefPerMaximo.PossuiValor and
    ((AValue.VrRefPerMaximo.Valor < 0) or
    (AValue.VrRefPerMaximo.Valor > 100)) then
    raise EModeloExameAnalitoValidacao.Create(
      'A referência percentual máxima deve estar entre 0 e 100.'
    );

  if AValue.VrRefPerMinimo.PossuiValor and
    AValue.VrRefPerMaximo.PossuiValor and
    (AValue.VrRefPerMinimo.Valor > AValue.VrRefPerMaximo.Valor) then
    raise EModeloExameAnalitoValidacao.Create(
      'A referência percentual mínima não pode ser maior que a máxima.'
    );
end;

procedure TModeloExameAnalitoService.ValidarReferencias(
  AValue: TModeloExameAnalito
);
var
  LAnalito: TAnalito;
  LAnalitoRepository: TAnalitoRepository;
  LExameAnalito: TExameAnalito;
  LExameAnalitoRepository: TExameAnalitoRepository;
  LNumero: Extended;
  LInteiro: Int64;
  LPossuiPercentual: Boolean;
begin
  LExameAnalitoRepository := TExameAnalitoRepository.Create;
  try
    LExameAnalito := LExameAnalitoRepository.FindById(AValue.IdExameAnalito);
    try
      if (not Assigned(LExameAnalito)) or (not LExameAnalito.StAtivo) then
        raise EModeloExameAnalitoValidacao.Create(
          'O analito do exame informado não está disponível.'
        );

      LAnalitoRepository := TAnalitoRepository.Create;
      try
        LAnalito := LAnalitoRepository.FindById(LExameAnalito.IdAnalito);
        try
          if (not Assigned(LAnalito)) or (not LAnalito.StAtivo) then
            raise EModeloExameAnalitoValidacao.Create(
              'O analito informado não está disponível.'
            );

          if AValue.VrRefMinimo.PossuiValor then
            case LAnalito.TpValor of
              tvaInteiro:
                if not TryStrToInt64(AValue.VrRefMinimo.Valor, LInteiro) then
                  raise EModeloExameAnalitoValidacao.Create(
                    'A referência mínima deve ser um número inteiro.'
                  );
              tvaDecimal:
                if not TryStrToFloat(AValue.VrRefMinimo.Valor, LNumero) then
                  raise EModeloExameAnalitoValidacao.Create(
                    'A referência mínima deve ser um número decimal.'
                  );
            end;

          if AValue.VrRefMaximo.PossuiValor then
            case LAnalito.TpValor of
              tvaInteiro:
                if not TryStrToInt64(AValue.VrRefMaximo.Valor, LInteiro) then
                  raise EModeloExameAnalitoValidacao.Create(
                    'A referência máxima deve ser um número inteiro.'
                  );
              tvaDecimal:
                if not TryStrToFloat(AValue.VrRefMaximo.Valor, LNumero) then
                  raise EModeloExameAnalitoValidacao.Create(
                    'A referência máxima deve ser um número decimal.'
                  );
            end;

          LPossuiPercentual := AValue.VrRefPerMinimo.PossuiValor or
            AValue.VrRefPerMaximo.PossuiValor;
          if LPossuiPercentual and not LAnalito.FgPercentual then
            raise EModeloExameAnalitoValidacao.Create(
              'Este analito não aceita referências percentuais.'
            );
        finally
          LAnalito.Free;
        end;
      finally
        LAnalitoRepository.Free;
      end;
    finally
      LExameAnalito.Free;
    end;
  finally
    LExameAnalitoRepository.Free;
  end;
end;

function TModeloExameAnalitoService.ListarPorModelo(
  AIdModeloExame: Int64
): TObjectList<TModeloExameAnalito>;
var
  LRepository: TModeloExameAnalitoRepository;
begin
  LRepository := TModeloExameAnalitoRepository.Create;
  try
    Result := LRepository.ListByModelo(AIdModeloExame);
  finally
    LRepository.Free;
  end;
end;

function TModeloExameAnalitoService.ObterPorId(
  AId: Int64
): TModeloExameAnalito;
var
  LRepository: TModeloExameAnalitoRepository;
begin
  LRepository := TModeloExameAnalitoRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if not Assigned(Result) then
      raise EModeloExameAnalitoNaoEncontrado.Create(
        'Item do modelo não encontrado.'
      );
  finally
    LRepository.Free;
  end;
end;

function TModeloExameAnalitoService.Criar(
  AValue: TModeloExameAnalito;
  AActorId: Int64
): TModeloExameAnalito;
var
  LRepository: TModeloExameAnalitoRepository;
begin
  NormalizarReferencias(AValue);
  Validar(AValue);
  ValidarReferencias(AValue);

  LRepository := TModeloExameAnalitoRepository.Create;
  try
    LRepository.Insert(AValue, AActorId);
    Result := AValue;
  finally
    LRepository.Free;
  end;
end;

function TModeloExameAnalitoService.Atualizar(
  AId: Int64;
  AValue: TModeloExameAnalito;
  AActorId: Int64
): TModeloExameAnalito;
var
  LRepository: TModeloExameAnalitoRepository;
begin
  NormalizarReferencias(AValue);
  Validar(AValue);
  ValidarReferencias(AValue);

  LRepository := TModeloExameAnalitoRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if (not Assigned(Result)) or (not Result.StAtivo) then
      raise EModeloExameAnalitoNaoEncontrado.Create(
        'Item do modelo não encontrado.'
      );

    Result.IdExameAnalito := AValue.IdExameAnalito;
    Result.DsSecao := AValue.DsSecao.Trim;
    Result.NrExibicao := AValue.NrExibicao;
    Result.DsRotulo := AValue.DsRotulo.Trim;
    Result.DsTecnica := AValue.DsTecnica.Trim;
    Result.DsUnidadeMedida := AValue.DsUnidadeMedida.Trim;
    Result.DsReferencia := AValue.DsReferencia.Trim;
    Result.VrRefMinimo := AValue.VrRefMinimo;
    Result.VrRefMaximo := AValue.VrRefMaximo;
    Result.VrRefPerMinimo := AValue.VrRefPerMinimo;
    Result.VrRefPerMaximo := AValue.VrRefPerMaximo;
    LRepository.Update(Result, AActorId);
  finally
    LRepository.Free;
  end;
end;

procedure TModeloExameAnalitoService.DefinirAtivo(
  AId: Int64;
  AAtivo: Boolean;
  AActorId: Int64
);
var
  LRepository: TModeloExameAnalitoRepository;
begin
  LRepository := TModeloExameAnalitoRepository.Create;
  try
    try
      LRepository.SetActive(AId, AAtivo, AActorId);
    except
      on E: EInvalidOp do
        raise EModeloExameAnalitoNaoEncontrado.Create(E.Message);
    end;
  finally
    LRepository.Free;
  end;
end;

end.
