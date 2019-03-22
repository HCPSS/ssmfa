import { Injectable } from '@angular/core'
import { HttpClient } from '@angular/common/http'
import { Observable, Observer, of, interval } from 'rxjs'
import { catchError, tap } from 'rxjs/operators'
import { JwtHelperService } from '@auth0/angular-jwt';
import { environment } from '../environments/environment'


const helper = new JwtHelperService()

@Injectable({
  providedIn: 'root'
})

export class LoginService {

  constructor(
    private http: HttpClient
  ) { }

  getToken(): Observable<any> {
    // check token in local storage
    let token = localStorage.getItem('authToken')
    if(!token || this.tokenAlmostExpired(token)){
      // token is bad return get token from SSO
      return this.http.get(
        environment.ssoReqToken,
        {withCredentials: true}
      ).pipe(
        tap(token => {
          localStorage.setItem('authToken', String(token))
        }),
        catchError(this.handleError<any>('getToken'))
      )
    }else{
      // token is ok, move on
      return Observable.create((obs: Observer<any>) => {
        obs.next(token)
      })
    }
  }

  // checks if token is close to expiry, clock skew
  tokenAlmostExpired(token: string) {
    const expiration = helper.getTokenExpirationDate(token)
    const now = new Date()
    // is less than 5 minutes ago
    return expiration.getTime() - (5 * 60 * 1000) < now.getTime()
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {

      // redirect unauthorized getToken requests to login
      if (`${operation}` === 'getToken'){
        window.location.href = environment.ssoRedirect
      }

      return of(result as T)
    }
  }

  // Check token every 5 seconds and send request for another one if close to expiry
  keepAlive() {
    return interval(5000).subscribe(
      () => {
        this.getToken().subscribe()
      }
    )
  }
}
