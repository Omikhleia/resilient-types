use clap::{CommandFactory, FromArgMatches};
use mlua::prelude::*;
use std::path::PathBuf;

use sile::cli::Cli;

fn main() -> sile::Result<()> {
    let version = option_env!("VERGEN_GIT_SEMVER").unwrap_or_else(|| env!("VERGEN_BUILD_SEMVER"));
    let app = Cli::command().version(version);
    #[allow(unused_variables)]
    let matches = app.get_matches();
    let args = Cli::from_arg_matches(&matches).expect("Unable to parse arguments");
    run_sile(args.input, args.debug, args.traceback)?;
    Ok(())
}

fn run_sile(input: PathBuf, debug: Option<Vec<String>>, traceback: bool) -> sile::Result<()> {
    let lua = unsafe { Lua::unsafe_new() };
    let sile: LuaTable = lua
        .load(
            r#"
            package.path = "./?.lua"
            local executable = require("core.pathsetup")()
            return require("core.sile")
            "#,
        )
        .eval()?;
    sile.set("traceback", traceback)?;
    if let Some(flags) = debug {
        sile.set("debugFlags", flags)?;
    }
    let full_version: String = sile.get("full_version")?;
    eprintln!("{full_version} [Rust]");
    let sile_input: LuaTable = sile.get("input")?;
    if let Some(expressions) = evaluate {
        sile_input.set("evaluates", expressions)?;
    }
    if let Some(expressions) = evaluate_after {
        sile_input.set("evaluateAfters", expressions)?;
    }
    if let Some(backend) = backend {
        sile.set("backend", backend)?;
    }
    if let Some(fontmanager) = fontmanager {
        sile.set("fontmanager", fontmanager)?;
    }
    if let Some(class) = class {
        sile_input.set("class", class)?;
    }
    if let Some(paths) = preamble {
        sile_input.set("preambles", pbs_to_sts(paths))?;
    }
    if let Some(paths) = postamble {
        sile_input.set("postamble", pbs_to_sts(paths))?;
    }
    if let Some(path) = makedeps {
        sile_input.set("makedeps", pb_to_st(&path))?;
    }
    if let Some(options) = options {
        sile_input.set("options", options)?;
    }
    if let Some(modules) = r#use {
        sile_input.set("use", modules)?;
    }
    let input_filename: LuaString = lua.create_string(&pb_to_st(&input))?;
    if let Some(path) = output {
        sile.set("outputFilename", pb_to_st(&path))?;
    }
    sile_input.set("filename", input_filename)?;
    let init: LuaFunction = sile.get("init")?;
    init.call::<_, _>(())?;
    let process_file: LuaFunction = sile.get("processFile")?;
    process_file.call::<LuaString, ()>(sile_input.get("filename")?)?;
    let finish: LuaFunction = sile.get("finish")?;
    finish.call::<(), ()>(())?;
    Ok(())
}
