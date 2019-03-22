import { Component } from '@angular/core'
import { LoginService } from './login.service'
import { ApiService } from './api.service'
import { Router } from '@angular/router'

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})

export class AppComponent {
  title = 'ssmfa'
  status: string
  recoveryEmail: string

  constructor (
    private apiService: ApiService,
    private loginService: LoginService,
    private router: Router
  ) { }

  ngOnInit() {
    if(window.location.pathname !== '/continue'){ // exclude continue for unauthenticated jwt redirects
      // require login to SSO
      this.loginService.getToken().subscribe()
      this.loginService.keepAlive();
      // keep trying to get the auth token every 300ms
      (async () => {
        while(!localStorage.getItem('authToken')){
          await new Promise(resolve => setTimeout(resolve, 300))
        }
        this.apiService.getRecoveryEmail()
          .subscribe((recoveryEmail) => {
            if(recoveryEmail.email){
              this.recoveryEmail = recoveryEmail.email
            }
          })
        this.apiService.getMFAStatus()
          .subscribe((status) => {
            this.status = status.status
            // redirect to setup
            if(status.status === 'disabled'){
              this.router.navigateByUrl('/setup')
            }
          })
      })()
    }
  }
}
