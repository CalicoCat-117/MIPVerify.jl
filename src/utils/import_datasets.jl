using MAT

export read_datasets

abstract type Dataset end

"""
$(TYPEDEF)

Dataset of images stored as a 4-dimensional array of size `(num_samples, image_height, 
image_width, num_channels)`, with accompanying labels (sorted in the same order) of size
`num_samples`.
"""
struct ImageDataset{T<:Real, U<:Int} <: Dataset
    images::Array{T, 4}
    labels::Array{U, 1}

    function ImageDataset{T, U}(images::Array{T, 4}, labels::Array{U, 1})::ImageDataset where {T<:Real, U<:Integer}
        (num_image_samples, image_height, image_width, num_channels) = size(images)
        (num_label_samples, ) = size(labels)
        @assert num_image_samples==num_label_samples
        return new(images, labels)
    end
end

function ImageDataset(images::Array{T, 4}, labels::Array{U, 1})::ImageDataset where {T<:Real, U<:Integer}
    ImageDataset{T, U}(images, labels)
end

function Base.show(io::IO, dataset::ImageDataset)
    image_size = size(dataset.images[1, :, :, :])
    num_samples = size(dataset.labels)[1]
    min_pixel = minimum(dataset.images)
    max_pixel = maximum(dataset.images)
    min_label = minimum(dataset.labels)
    max_label = maximum(dataset.labels)
    num_unique_labels = length(unique(dataset.labels))
    print(io,
        "{ImageDataset}",
        "\n    `images`: $num_samples images of size $image_size, with pixels in [$min_pixel, $max_pixel].",
        "\n    `labels`: $num_samples corresponding labels, with $num_unique_labels unique labels in [$min_label, $max_label]."
    )
end

"""
$(TYPEDEF)

Named dataset containing a training set and a test set which are expected to contain the
same kind of data.
"""
struct NamedTrainTestDataset{T<:Dataset} <: Dataset
    name::String
    train::T
    test::T
end

function Base.show(io::IO, dataset::NamedTrainTestDataset)
    print(io, 
        "$(dataset.name):",
        "\n  `train`: $(dataset.train)",
        "\n  `test`: $(dataset.test)"
    )
end

"""
$(SIGNATURES)

Makes popular machine learning datasets available as a `NamedTrainTestDataset`.

# Arguments
* `name::String`: name of machine learning dataset. Options:
    * `MNIST`: [The MNIST Database of handwritten digits](http://yann.lecun.com/exdb/mnist/)
"""
function read_datasets(name::String)::NamedTrainTestDataset
    if name == "MNIST"

        MNIST_dir = joinpath("datasets", "mnist")

        m_train = prep_data_file(MNIST_dir, "mnist_train.mat") |> matread
        train = ImageDataset(m_train["images"], m_train["labels"][:])

        m_test = prep_data_file(MNIST_dir, "mnist_test.mat") |> matread
        test = ImageDataset(m_test["images"], m_test["labels"][:])
        return NamedTrainTestDataset(name, train, test)
    else
        throw(DomainError("Dataset $name not supported."))
    end
end