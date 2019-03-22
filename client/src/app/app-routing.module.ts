import { NgModule } from '@angular/core'
import { Routes, RouterModule } from '@angular/router'
import { SetupComponent } from './setup/setup.component'
import { ContinueComponent } from './continue/continue.component'

const routes: Routes = [
  { path: 'setup', component: SetupComponent },
  { path: 'continue', component: ContinueComponent },
]

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
