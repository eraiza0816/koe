FROM rust:1.94.1-bookworm AS builder

RUN apt-get update && \
    apt-get install -y libopus-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root/koe

COPY Cargo.toml Cargo.lock ./

RUN --mount=type=bind,source=src,target=src \
    --mount=type=cache,target=/root/koe/target,sharing=locked \
    --mount=type=cache,target=/usr/local/cargo/registry,sharing=locked \
    --mount=type=cache,target=/usr/local/cargo/git/db,sharing=locked \
    cargo build --release --bin koe && \
    cp target/release/koe /usr/local/bin/koe
# --mount=type=bind,source=Cargo.toml,target=Cargo.toml \
# --mount=type=bind,source=Cargo.lock,target=Cargo.lock \

###

FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y ca-certificates libopus0 && \
    rm -rf /var/lib/apt/lists/*

# Switch to unpriviledged user
RUN useradd --user-group koe
USER koe

COPY --from=builder /usr/local/bin/koe /usr/local/bin/koe

ENTRYPOINT ["koe"]
