unit USerialconsole;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls, PairSplitter, LazSerial, TAGraph, TASeries, LazSynaSer;

type
  PTSerialPort = ^TLazSerial;

type
  PTMemo = ^TMemo;

{ TReceiverThread }
type
  TReceiverThread = class(TThread)
private
  FBuffer: PTMemo;
  FPTSerialPort: PTSerialPort;
  FRun: Boolean;
  buf : String;
public
  property run : Boolean read FRun write FRun default True;
  property SerialPort : PTSerialPort read FPTSerialPort write FPTSerialPort;
  property buffer : PTMemo read FBuffer write FBuffer;
  procedure execute; override;
  procedure updateVisual;
  constructor Create;
  destructor Destroy; override;
end;

type

  { TFrmPlotter }

  TFrmPlotter = class(TForm)
    btnConectar: TButton;
    btnLimpar: TButton;
    btnAtualizar: TButton;
    Button1: TButton;
    cboBaudRate: TComboBox;
    cboPortas: TComboBox;
    Memo1: TMemo;
    txtMsg: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LazSerial1: TLazSerial;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnConectarClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    Receiver: TReceiverThread;
    procedure updateSerial;
    procedure PopulaBaud;
  public

  end;

var
  FrmPlotter: TFrmPlotter;

implementation

{$R *.lfm}

{ TReceiverThread }

procedure TReceiverThread.execute;
begin
  while FRun do
    begin
     if FPTSerialPort^.DataAvailable then
      begin
       buf := buf + FPTSerialPort^.ReadData;
       Synchronize(@updateVisual);
      end;
      Sleep(200);
    end;
end;

procedure TReceiverThread.updateVisual;
begin
 buffer^.Lines.Add(buf);
 buf := EmptyStr;
 buffer^.SelStart := Length(buffer^.Text);
end;

constructor TReceiverThread.Create;
begin
  inherited Create(True);
  FRun := True;
end;

destructor TReceiverThread.Destroy;
begin
  inherited Destroy;
end;

{ TFrmPlotter }

procedure TFrmPlotter.FormCreate(Sender: TObject);
begin
  updateSerial;
  PopulaBaud;

  Receiver := TReceiverThread.create();
  Receiver.FreeOnTerminate:= True;
  Receiver.FPTSerialPort:=@LazSerial1;
  Receiver.buffer:=@Memo1;
  Receiver.Start;
end;


procedure TFrmPlotter.btnAtualizarClick(Sender: TObject);
begin
  updateSerial;
  PopulaBaud;
end;

procedure TFrmPlotter.btnConectarClick(Sender: TObject);
begin
  if cboPortas.Items[cboPortas.ItemIndex] = EmptyStr then
  begin
    Application.MessageBox('Você Primeiro Deve Selecionar a Porta Serial','Porta Inválida');
  end;

  if cboBaudRate.Items[cboBaudRate.ItemIndex] = EmptyStr then
  begin
    Application.MessageBox('Você Primeiro Deve Selecionar um Baud Rate','Baud Rate Inválido');
  end;

   with LazSerial1 do
   begin
     if not Active then
       begin
        device   := cboPortas.Items[cboPortas.ItemIndex];
        BaudRate := TBaudRate(cboBaudRate.ItemIndex);
        Active:=True;
        btnConectar.Caption:='Desconectar';
       end else
        begin
          device   := EmptyStr;
          BaudRate := br_____0;
          Active:=False;
          btnConectar.Caption:='Conectar';
        end;
   end;

  if LazSerial1.Active then
     begin
       cboBaudRate.Enabled:=False;
       btnAtualizar.Enabled:=False;
       cboPortas.Enabled:=False;
       btnLimpar.Enabled:=True;
       Memo1.Lines.Clear;
     end else
      begin
        cboBaudRate.Enabled:=True;
        btnAtualizar.Enabled:=True;
        cboPortas.Enabled:=True;
        btnLimpar.Enabled:=False;
        Memo1.Lines.Clear;
      end;

end;

procedure TFrmPlotter.btnLimparClick(Sender: TObject);
begin
 Memo1.Lines.Clear;
end;

procedure TFrmPlotter.Button1Click(Sender: TObject);
begin
  if txtMsg.Text = EmptyStr then
   begin
     Application.MessageBox('A Mensagem Não pode Ficar Vazia','Mensagem Inválida');
     exit;
   end;

  LazSerial1.WriteData(txtMsg.Text);
end;

procedure TFrmPlotter.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  LazSerial1.Active := False;


  Receiver.run := False;
  Receiver.Terminate;
  FreeAndNil(receiver);
end;

procedure TFrmPlotter.PopulaBaud;
var
 i : TBaudRate;
 bauds : TStringList;
begin
  bauds := TStringList.create;
  for i := br_____0 to high(LazSerial.ConstsBaud) do
  begin
    bauds.Add(IntToStr(LazSerial.ConstsBaud[i]));
  end;
  cboBaudRate.Items.CommaText := bauds.CommaText;
  cboBaudRate.ItemIndex := 0 ;
end;

procedure TFrmPlotter.updateSerial;
begin
 cboPortas.Items.CommaText := GetSerialPortNames;
 cboPortas.ItemIndex := 0 ;
end;

end.

