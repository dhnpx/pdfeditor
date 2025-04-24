pub const DocumentError = error{
    FailedToCreateContext,
    FailedToOpenDocument,
    InvalidPageNumber,
    UnsupportedFileFormat,
};

pub const RenderError = error{
    FailedToCreatePixmap,
};

pub const WriterError = error{
    FailedToCreateWriter,
};
