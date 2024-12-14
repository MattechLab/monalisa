function updatePlot(plotHandle, selectedBin, sequentialBinningMask, timestampMs)
    % Update the plot's YData to the selected bin's data
    plotHandle.YData = sequentialBinningMask(selectedBin, :);
    
    % Update the title to reflect the selected bin
    plotHandle.Parent.Title.String = ['Sequential Binning Mask: Bin ' num2str(selectedBin)];
end