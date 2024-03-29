R__ADD_INCLUDE_PATH($VMCWORKDIR)
#include "macro/run/geometry_run/geometry_run8.C"

#define GEANT4  // Choose: GEANT3 GEANT4
// enumeration of generator names corresponding input files
enum enumGenerators{URQMD, QGSM, HSD, BOX, PART, ION, DCMQGSM, DCMSMM};

// inFile - input file with generator data, if needed
// outFile - output file with MC data, default: bmnsim.root
// nStartEvent - start event in the input generator file to begin transporting, default: 0
// nEvents - number of events to transport
// generatorName - generator name for the input file (enumeration above)
// useRealEffects - whether we use realistic effects at simulation (Lorentz, misalignment)
void run_sim_bmn(TString inFile = "DCMSMM_XeCsI_3.9AGeV_mb_10k_142.r12", TString outFile = "$VMCWORKDIR/macro/run8/bmnsim.root",
    Int_t nStartEvent = 0, Int_t nEvents = 1, enumGenerators generatorName = BOX, Bool_t useRealEffects = kTRUE) {
std::cout << "Point 00.1" << std::endl;
    TStopwatch timer;
std::cout << "Point 00.2" << std::endl;
    timer.Start();
std::cout << "Point 00.3" << std::endl;
    gDebug = 0;
std::cout << "Point 00.4" << std::endl;
	
std::cout << "Point 0.1" << std::endl;
    // -----   Create simulation run   ----------------------------------------
    FairRunSim* fRun = new FairRunSim();
std::cout << "Point 0.2" << std::endl;
    // Choose the Geant Navigation System
#ifdef GEANT4
    fRun->SetName("TGeant4");
#else
    fRun->SetName("TGeant3");
#endif
std::cout << "Point 0.3" << std::endl;
    geometry(fRun); // load BM@N geometry
std::cout << "Point 0.4" << std::endl;
    // Use the experiment specific MC Event header instead of the default one
    // This one stores additional information about the reaction plane
    //MpdMCEventHeader* mcHeader = new MpdMCEventHeader();
    //fRun->SetMCEventHeader(mcHeader);

    // Create and Set Event Generator
    FairPrimaryGenerator* primGen = new FairPrimaryGenerator();
    fRun->SetGenerator(primGen);
std::cout << "Point 0.5" << std::endl;
    // Smearing of beam interaction point, if needed, and primary vertex position
    // DO NOT do it in corresponding gen. sections to avoid incorrect summation!!!
    primGen->SetBeam(0.0, 0.0, 1.6, 1.6);  // (beamX0, beamY0, beamSigmaX, beamSigmaY)
    primGen->SetTarget(0.0875, 0.0875);    // (targetZ, targetDz)
    primGen->SmearVertexZ(kTRUE);
    primGen->SmearVertexXY(kTRUE);
    gRandom->SetSeed(0);
std::cout << "Point 0.6" << std::endl;
    switch (generatorName)
    {
    // ------- UrQMD Generator
    case URQMD:{
	std::cout << "Initialization of the input" << std::endl;
        if (!BmnFunctionSet::CheckFileExist(inFile, 1)) exit(-1);
	std::cout << "Point 1" << std::endl;
        MpdUrqmdGenerator* urqmdGen = new MpdUrqmdGenerator(inFile);
        std::cout << "Point 2" << std::endl;
	urqmdGen->SetEventPlane(0., 360.);
	std::cout << "Point 3" << std::endl;
        primGen->AddGenerator(urqmdGen);
	std::cout << "Point 4" << std::endl;
        if (nStartEvent > 0) urqmdGen->SkipEvents(nStartEvent);
	std::cout << "Point 5" << std::endl;
        if (nEvents == 0)
            nEvents = MpdGetNumEvents::GetNumURQMDEvents(inFile.Data()) - nStartEvent;
	std::cout << "Point 6" << std::endl;
        break;
    }

    // ------- Particle Generator
    case PART:{
        // FairParticleGenerator generates a single particle type (PDG, mult, [GeV] px, py, pz, [cm] vx, vy, vz)
        FairParticleGenerator* partGen = new FairParticleGenerator(211, 10, 1, 0, 3, 1, 0, 0);
        primGen->AddGenerator(partGen);
        break;
    }

    // ------- Ion Generator
    case ION:{
        // Start beam from a far point to check mom. reconstruction procedure (Z, A, q, mult, [GeV] px, py, pz, [cm] vx, vy, vz)
        FairIonGenerator* fIongen = new FairIonGenerator(54, 131, 54, 1, 0., 0., -4.8, 0., 0., 0.); //Xe
        primGen->AddGenerator(fIongen);
        break;
    }

    // ------- Box Generator
    case BOX:{
        gRandom->SetSeed(0);
        FairBoxGenerator* boxGen = new FairBoxGenerator(2212, 1); // 13 = muon; 1 = multipl.
        boxGen->SetPRange(0.2, 5.0);      // GeV/c, setPRange vs setPtRange
        boxGen->SetPhiRange(0, 360);    // Azimuth angle range [degree]
        boxGen->SetThetaRange(0, 40.0);  // Polar angle in lab system range [degree]
        primGen->AddGenerator(boxGen);
        break;
    }

    // ------- HSD/PHSD Generator
    case HSD:{
        if (!BmnFunctionSet::CheckFileExist(inFile, 1)) exit(-1);

        MpdPHSDGenerator* hsdGen = new MpdPHSDGenerator(inFile.Data());
        //hsdGen->SetPsiRP(0.); // set fixed Reaction Plane angle instead of random
        primGen->AddGenerator(hsdGen);
        if (nStartEvent > 0) hsdGen->SkipEvents(nStartEvent);

        // if nEvents is equal 0 then all events (start with nStartEvent) of the given file should be processed
        if (nEvents == 0)
            nEvents = MpdGetNumEvents::GetNumPHSDEvents(inFile.Data()) - nStartEvent;
        break;
    }

    // ------- LAQGSM/DCM-QGSM Generator
    case QGSM:
    case DCMQGSM:{

        if (!BmnFunctionSet::CheckFileExist(inFile, 1)) exit(-1);

        MpdLAQGSMGenerator* guGen = new MpdLAQGSMGenerator(inFile.Data(), kFALSE);
        primGen->AddGenerator(guGen);
        if (nStartEvent > 0) guGen->SkipEvents(nStartEvent);

        // if nEvents is equal 0 then all events (start with nStartEvent) of the given file should be processed
        if (nEvents == 0)
            nEvents = MpdGetNumEvents::GetNumQGSMEvents(inFile.Data()) - nStartEvent;
        break;
    }
    case DCMSMM:{

        if (!BmnFunctionSet::CheckFileExist(inFile, 1)) exit(-1);

        MpdDCMSMMGenerator* smmGen = new MpdDCMSMMGenerator(inFile.Data());
        primGen->AddGenerator(smmGen);
        if (nStartEvent > 0) smmGen->SkipEvents(nStartEvent);

        // if nEvents is equal 0 then all events (start with nStartEvent) of the given file should be processed
        if (nEvents == 0)
            nEvents = MpdGetNumEvents::GetNumDCMSMMEvents(inFile.Data()) - nStartEvent;
        break;
    }

    default: { cout<<"ERROR: Generator name was not pre-defined: "<<generatorName<<endl; exit(-3); }
    }// end of switch (generatorName)
    std::cout << "The generator has been initialized" << std::endl;
    // if directory for the output file does not exist, then create
    if (BmnFunctionSet::CreateDirectoryTree(outFile, 1) < 0) exit(-2);
    fRun->SetSink(new FairRootFileSink(outFile.Data()));
    fRun->SetIsMT(false);

    // -----   Create magnetic field   ----------------------------------------
    BmnFieldMap* magField = new BmnNewFieldMap("field_sp41v5_ascii_Extrap.root");
    Double_t fieldScale = 1800. / 900.;
    magField->SetScale(fieldScale);
    fRun->SetField(magField);

    fRun->SetStoreTraj(kTRUE);
    fRun->SetRadLenRegister(kFALSE); // radiation length manager


    // -----   Digitizers: converting MC points to detector digits   -----------
    // SiBT-Digitizer
    BmnSiBTConfiguration::SiBT_CONFIG sibt_config = BmnSiBTConfiguration::Run8;
    BmnSiBTDigitizer* sibtDigit = new BmnSiBTDigitizer();
    sibtDigit->SetCurrentConfig(sibt_config);
    fRun->AddTask(sibtDigit);
    
    // SiMD-Digitizer
    BmnSiMDDigitizer* simdDigit = new BmnSiMDDigitizer();
    fRun->AddTask(simdDigit);

    // SI-Digitizer
    BmnSiliconConfiguration::SILICON_CONFIG si_config = BmnSiliconConfiguration::Run8_3stations;
    BmnSiliconDigitizer* siliconDigit = new BmnSiliconDigitizer();
    siliconDigit->SetCurrentConfig(si_config);
    siliconDigit->SetUseRealEffects(useRealEffects);
    fRun->AddTask(siliconDigit);

    // GEM-Digitizer
    BmnGemStripConfiguration::GEM_CONFIG gem_config = BmnGemStripConfiguration::Run8;
    if (useRealEffects)
        BmnGemStripMedium::GetInstance().SetCurrentConfiguration(BmnGemStripMediumConfiguration::ARC4H10_80_20_E_1720_2240_3230_3730_B_0_8T);
    BmnGemStripDigitizer* gemDigit = new BmnGemStripDigitizer();
    gemDigit->SetCurrentConfig(gem_config);
    gemDigit->SetUseRealEffects(useRealEffects);
    fRun->AddTask(gemDigit);

    // CSC-Digitizer
    BmnCSCConfiguration::CSC_CONFIG csc_config = BmnCSCConfiguration::Run8;
    BmnCSCDigitizer* cscDigit = new BmnCSCDigitizer();
    cscDigit->SetCurrentConfig(csc_config);
    fRun->AddTask(cscDigit);
    
    //FHCal-Digitizer
    // BmnFHCalDigitizer * fhcalDigit = new BmnFHCalDigitizer();
    // fhcalDigit->SetScale(28.2e3);
    // fhcalDigit->SetThreshold(0.);
    // fRun->AddTask(fhcalDigit);
    
    // ECAL-Digitizer
    // FIXME some problems with channels
    // BmnEcalDigitizer * ecalDigit = new BmnEcalDigitizer();
    // fRun->AddTask(ecalDigit);

    fRun->Init();
    magField->Print("");

    // Trajectories Visualization (TGeoManager only)
    FairTrajFilter* trajFilter = FairTrajFilter::Instance();
    // Set cuts for storing the trajectories
    trajFilter->SetStepSizeCut(0.01); // [cm]
    trajFilter->SetVertexCut(-200., -200., -1000., 200., 200., 1100.); // (vxMin, vyMin, vzMin, vxMax, vyMax, vzMax)
    trajFilter->SetMomentumCutP(30e-3); // p_lab > 30 MeV
    trajFilter->SetEnergyCut(0., 10.);  // 0 < Etot < 10 GeV
    trajFilter->SetStorePrimaries(kTRUE);
    trajFilter->SetStoreSecondaries(kTRUE); //kFALSE

    // Fill the Parameter containers for this run
    FairRuntimeDb *rtdb = fRun->GetRuntimeDb();

    BmnFieldPar* fieldPar = (BmnFieldPar*) rtdb->getContainer("BmnFieldPar");
    fieldPar->SetParameters(magField);
    fieldPar->setChanged();
    fieldPar->setInputVersion(fRun->GetRunId(), 1);
    Bool_t kParameterMerged = kTRUE;
    FairParRootFileIo* output = new FairParRootFileIo(kParameterMerged);
    //AZ output->open(parFile.Data());
    output->open(gFile);
    rtdb->setOutput(output);

    rtdb->saveOutput();
    rtdb->print();

    // Transport nEvents
    fRun->Run(nEvents);

    //gGeoManager->CheckOverlaps(0.0001);
    //gGeoManager->PrintOverlaps();

    fRun->CreateGeometryFile("full_geometry.root");  // save the full setup geometry to the additional file

if ((generatorName == QGSM) || (generatorName == DCMQGSM)){
    TString Pdg_table_name = TString::Format("%s%s%c%s", gSystem->BaseName(inFile.Data()), ".g", (fRun->GetName())[6], ".pdg_table.dat");
    (TDatabasePDG::Instance())->WritePDGTable(Pdg_table_name.Data());
}

    timer.Stop();
    Double_t rtime = timer.RealTime(), ctime = timer.CpuTime();
    printf("RealTime=%f seconds, CpuTime=%f seconds\n", rtime, ctime);
    cout << "Macro finished successfully." << endl; // marker of successfully execution for software testing systems
    delete fRun;
}
