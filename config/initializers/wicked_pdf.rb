WickedPdf.config ||= {}
WickedPdf.config.merge!(
  {
    layout: "pdf.html.erb",
    template: 'trips/trip.html.erb'
  }
)
