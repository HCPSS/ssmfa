import { Injectable } from '@angular/core'
import { environment } from '../environments/environment'
import { Observable, of } from 'rxjs'
import { catchError } from 'rxjs/operators'
import {
  HttpClient,
  HttpHeaders
} from '@angular/common/http'

@Injectable({
  providedIn: 'root'
})
export class ApiService {

  private url = environment.baseUrl + '/api/'

  constructor(
    private http: HttpClient
  ) { }

  // generate options for http that include the token from local storage
  getAuthOptions = () => {
    return {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + localStorage.getItem('authToken')
      })
    }
  }

  getMFAStatus(): Observable<any> {
    return this.http.get(this.url + 'user/status', this.getAuthOptions())
      .pipe(
        catchError(this.handleError('getMFAStatus', []))
      )
  }

  getRecoveryEmail(): Observable<any> {
    return this.http.get(this.url + 'user/recoveryEmail', this.getAuthOptions())
      .pipe(
        catchError(this.handleError('getRecoveryEmail', []))
      )
  }

  postRequestRecoveryEmail(email: string): Observable<any> {
    const body = {
      email: email
    }
    return this.http.post(this.url + 'user/requestRecoveryEmail', body, this.getAuthOptions())
      .pipe(
        catchError(this.handleError('postRequestRecoveryEmail', []))
      )
  }

  postRequestMFASettingsReset(): Observable<any> {
    const body = {
      reset: true
    }
    return this.http.post(this.url + 'user/requestMFASettingsReset', body, this.getAuthOptions())
      .pipe(
        catchError(this.handleError('postRequestMFASettingsReset', []))
      )
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      // Let the app keep running by returning an empty result.
      return of(result as T)
    }
  }
}
