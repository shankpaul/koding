package j_stack_template

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"net/http"
	"time"

	"golang.org/x/net/context"

	"github.com/go-openapi/errors"
	"github.com/go-openapi/runtime"
	cr "github.com/go-openapi/runtime/client"

	strfmt "github.com/go-openapi/strfmt"

	"koding/remoteapi/models"
)

// NewPostRemoteAPIJStackTemplateVerifyIDParams creates a new PostRemoteAPIJStackTemplateVerifyIDParams object
// with the default values initialized.
func NewPostRemoteAPIJStackTemplateVerifyIDParams() *PostRemoteAPIJStackTemplateVerifyIDParams {
	var ()
	return &PostRemoteAPIJStackTemplateVerifyIDParams{

		timeout: cr.DefaultTimeout,
	}
}

// NewPostRemoteAPIJStackTemplateVerifyIDParamsWithTimeout creates a new PostRemoteAPIJStackTemplateVerifyIDParams object
// with the default values initialized, and the ability to set a timeout on a request
func NewPostRemoteAPIJStackTemplateVerifyIDParamsWithTimeout(timeout time.Duration) *PostRemoteAPIJStackTemplateVerifyIDParams {
	var ()
	return &PostRemoteAPIJStackTemplateVerifyIDParams{

		timeout: timeout,
	}
}

// NewPostRemoteAPIJStackTemplateVerifyIDParamsWithContext creates a new PostRemoteAPIJStackTemplateVerifyIDParams object
// with the default values initialized, and the ability to set a context for a request
func NewPostRemoteAPIJStackTemplateVerifyIDParamsWithContext(ctx context.Context) *PostRemoteAPIJStackTemplateVerifyIDParams {
	var ()
	return &PostRemoteAPIJStackTemplateVerifyIDParams{

		Context: ctx,
	}
}

/*PostRemoteAPIJStackTemplateVerifyIDParams contains all the parameters to send to the API endpoint
for the post remote API j stack template verify ID operation typically these are written to a http.Request
*/
type PostRemoteAPIJStackTemplateVerifyIDParams struct {

	/*Body
	  body of the request

	*/
	Body models.DefaultSelector
	/*ID
	  Mongo ID of target instance

	*/
	ID string

	timeout    time.Duration
	Context    context.Context
	HTTPClient *http.Client
}

// WithTimeout adds the timeout to the post remote API j stack template verify ID params
func (o *PostRemoteAPIJStackTemplateVerifyIDParams) WithTimeout(timeout time.Duration) *PostRemoteAPIJStackTemplateVerifyIDParams {
	o.SetTimeout(timeout)
	return o
}

// SetTimeout adds the timeout to the post remote API j stack template verify ID params
func (o *PostRemoteAPIJStackTemplateVerifyIDParams) SetTimeout(timeout time.Duration) {
	o.timeout = timeout
}

// WithContext adds the context to the post remote API j stack template verify ID params
func (o *PostRemoteAPIJStackTemplateVerifyIDParams) WithContext(ctx context.Context) *PostRemoteAPIJStackTemplateVerifyIDParams {
	o.SetContext(ctx)
	return o
}

// SetContext adds the context to the post remote API j stack template verify ID params
func (o *PostRemoteAPIJStackTemplateVerifyIDParams) SetContext(ctx context.Context) {
	o.Context = ctx
}

// WithBody adds the body to the post remote API j stack template verify ID params
func (o *PostRemoteAPIJStackTemplateVerifyIDParams) WithBody(body models.DefaultSelector) *PostRemoteAPIJStackTemplateVerifyIDParams {
	o.SetBody(body)
	return o
}

// SetBody adds the body to the post remote API j stack template verify ID params
func (o *PostRemoteAPIJStackTemplateVerifyIDParams) SetBody(body models.DefaultSelector) {
	o.Body = body
}

// WithID adds the id to the post remote API j stack template verify ID params
func (o *PostRemoteAPIJStackTemplateVerifyIDParams) WithID(id string) *PostRemoteAPIJStackTemplateVerifyIDParams {
	o.SetID(id)
	return o
}

// SetID adds the id to the post remote API j stack template verify ID params
func (o *PostRemoteAPIJStackTemplateVerifyIDParams) SetID(id string) {
	o.ID = id
}

// WriteToRequest writes these params to a swagger request
func (o *PostRemoteAPIJStackTemplateVerifyIDParams) WriteToRequest(r runtime.ClientRequest, reg strfmt.Registry) error {

	r.SetTimeout(o.timeout)
	var res []error

	if err := r.SetBodyParam(o.Body); err != nil {
		return err
	}

	// path param id
	if err := r.SetPathParam("id", o.ID); err != nil {
		return err
	}

	if len(res) > 0 {
		return errors.CompositeValidationError(res...)
	}
	return nil
}
