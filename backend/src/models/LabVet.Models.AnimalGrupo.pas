unit LabVet.Models.AnimalGrupo;

interface

uses
  System.Generics.Collections,
  LabVet.Models.Base;

type
  TAnimalGrupo = class(TEntidadeAuditavel)
  private
    FFilhos: TObjectList<TAnimalGrupo>;
  public
    IdAnimalGrupo: Int64;
    IdAnimalGrupoPai: TInteiro64Opcional;
    NmAnimalGrupo: string;
    DsDescricao: string;
    constructor Create;
    destructor Destroy; override;
    property Filhos: TObjectList<TAnimalGrupo> read FFilhos;
  end;

implementation

constructor TAnimalGrupo.Create;
begin
  inherited Create;
  StAtivo := True;
  FFilhos := TObjectList<TAnimalGrupo>.Create(True);
end;

destructor TAnimalGrupo.Destroy;
begin
  FFilhos.Free;
  inherited Destroy;
end;

end.
