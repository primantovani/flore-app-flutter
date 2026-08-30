import { Injectable, signal } from '@angular/core';

export interface Toast {
  mensagem: string;
  tipo: 'sucesso' | 'erro';
}

/// Feedback visual leve (ex: "Peça cadastrada com sucesso"), renderizado
/// globalmente pelo AppComponent. Evita repetir alert()/console.log em
/// cada tela.
@Injectable({
  providedIn: 'root'
})
export class ToastService {
  readonly toast = signal<Toast | null>(null);
  private timeoutId?: ReturnType<typeof setTimeout>;

  sucesso(mensagem: string): void {
    this.mostrar({ mensagem, tipo: 'sucesso' });
  }

  erro(mensagem: string): void {
    this.mostrar({ mensagem, tipo: 'erro' });
  }

  private mostrar(toast: Toast): void {
    clearTimeout(this.timeoutId);
    this.toast.set(toast);
    this.timeoutId = setTimeout(() => this.toast.set(null), 3500);
  }
}
